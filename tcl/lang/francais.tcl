### francais.tcl:
#
# French language support for Scid.
# Translations contributed by:
# Gilles Maire, Vincent Serisier, Joel Rivat, and Pascal Heisel.

proc setLanguage_F {} {

# File menu:
menuText F File "Fichier" 0
menuText F FileNew "Nouvelle..." 0 {Créer une nouvelle base de données Scid}
menuText F FileOpen "Ouvrir..." 0 {Ouvrir une base de données Scid existante}
menuText F FileClose "Fermer" 0 {Fermer la base de données Scid active}
menuText F FileFinder "Trouver" 0 {Ouvrir la fenêtre de recherche de fichier}
menuText F FileBookmarks "Signets" 0 {Menu des signets (raccourci: Ctrl+B)}
menuText F FileBookmarksAdd "Ajouter un signet" 0 \
  {Poser un signet pour la position et partie courante}
menuText F FileBookmarksFile "Classer un signet" 0 \
  {Classer un signet pour la position et partie courante}
menuText F FileBookmarksEdit "Modifier les signets..." 0 \
  {Modifier les menus de signets}
menuText F FileBookmarksList "Afficher les dossiers comme une simple liste" 0 \
  {Afficher les dossiers comme une simple liste et non comme des sous-menus}
menuText F FileBookmarksSub "Afficher les dossiers comme des sous-menus" 0 \
  {Afficher les dossiers comme des sous-menus et non comme une simple liste}
menuText F FileMaint "Maintenance" 0 {Maintenance de la base}
menuText F FileMaintWin "Fenêtre de maintenance" 0 \
  {Ouvrir/Fermer la fenêtre de maintenance}
menuText F FileMaintCompact "Compacter la base..." 0 \
  {Compacter la base: supprimer les parties effacées et les noms non utilisés}
menuText F FileMaintClass "Classer les parties suivant ECO" 2 \
  {Recalculer le code ECO de toutes les parties}
menuText F FileMaintSort "Trier la base..." 0 {Trier toutes les parties de la base}
menuText F FileMaintDelete "Purger les doublons..." 0 \
  {Trouver les parties en doublons et les marquer pour l'effacement}
menuText F FileMaintTwin "Trouver les doublons" 0 \
  {Ouvrir/Actualiser la fenêtre de recherche de doublons}
menuText F FileMaintName "Orthographie des noms" 0 {Édition des noms et outils orthographiques}
menuText F FileMaintNameEditor "Éditeur de noms" 11 {Ouvrir/Fermer l'éditeur de noms}
menuText F FileMaintNamePlayer "Corriger les noms de joueurs..." 21 \
  {Vérifier l'orthographe des noms de joueurs}
menuText F FileMaintNameEvent "Corriger les événements..." 14 \
  {Vérifier l'orthographe des noms d'événements}
menuText F FileMaintNameSite "Corriger les noms de lieux.." 21 \
  {Vérifier l'orthographe des noms de lieux}
menuText F FileMaintNameRound "Corriger les noms des rondes..." 22 \
  {Vérifier l'orthographe des noms de rondes}
menuText F FileReadOnly "Lecture seule..." 0 \
  {Traiter la base courante en lecture seule, en empêchant les changements}
menuText F FileSwitch "Changer de base" 0 \
  {Changer vers une base ouverte différente}
menuText F FileExit "Quitter" 0 {Quitter Scid}
menuText F FileMaintFixBase "Réparer base" 0 {Essaie de réparer une base corrompue}

# Edit menu:
menuText F Edit "Éditer" 0
menuText F EditAdd "Ajouter variante" 0 {Ajouter une variante}
menuText F EditDelete "Effacer variante" 0 {Effacer cette variante}
menuText F EditFirst "Déplacer en tête" 0 \
  {Déplacer cette variante en tête de liste}
menuText F EditMain "Variante vers ligne principale" 13 \
   {Promouvoir une variante en ligne principale}
menuText F EditTrial "Essayer une variante" 0 \
  {Démarrer/Stopper mode d'essai, pour tester une idée sur l'échiquier}
menuText F EditStrip "Épurer" 2 {Épurer les commentaires ou les variantes de cette partie}
menuText F EditUndo "Annuler" 0 {Annuler la dernière modification de la partie}
menuText F EditRedo "Rétablir" 0 {Redo last game change}
menuText F EditStripComments "Commentaires" 0 \
  {Épurer cette partie de tous les commentaires et annotations}
menuText F EditStripVars "Variantes" 0 {Épurer cette partie des variantes}
menuText F EditStripBegin "Coups depuis le début" 1 \
  {Épurer cette partie des coups depuis le début}
menuText F EditStripEnd "Coups jusqu'à la fin" 0 \
  {Épurer cette partie des coups jusqu'à la fin}
menuText F EditReset "Vider le presse-papier" 0 {Vider le presse-papier}
menuText F EditCopy "Copier dans la base presse-papier" 0 \
  {Copier la partie en cours dans la base clipbase (9)}
menuText F EditPaste "Coller depuis la base presse-papier" 1 \
  {Copier la partie contenue dans la base clipbase (9) à cet emplacement}
menuText F EditPastePGN "Coller le presse-papier comme partie PGN..." 10 \
  {Interpréter le texte du presse-papiers comme de la notation PGN et le coller ici}
menuText F EditSetup "Position de départ" 0 \
  {Choisir une position de départ pour cette partie}
menuText F EditCopyBoard "Copier la position" 6 \
  {Copier la position en cours en notation FEN vers la sélection de texte (presse-papier)}
menuText F EditPasteBoard "Coller la position de départ" 12 \
  {Initialiser la position de départ à partir de la sélection de texte courante(presse-papier)}

# Game menu:
menuText F Game "Partie" 0
menuText F GameNew "Nouvelle partie" 2 \
  {Remettre à zéro la partie}
menuText F GameFirst "Charger la première partie" 5 {Charger la première partie du filtre}
menuText F GamePrev "Partie précédente" 7 \
  {Charger la partie précédente du filtre}
menuText F GameReload "Recharger la partie" 2 \
  {Recharger la partie (les modifications ne seront pas sauvegardées)}
menuText F GameNext "Partie suivante" 7 {Charger la partie suivante du filtre}
menuText F GameLast "Charger la dernière partie" 5 {Charger la dernière partie du filtre}
menuText F GameRandom "Charger une partie au hasard" 8 {Charger au hasard une partie du filtre}
menuText F GameNumber "Partie numéro..." 9 \
  {Charger une partie en donnant son numéro}
menuText F GameReplace "Enregistrer: Remplacer la partie..." 13 \
  {Enregistrer cette partie, en écrasant l'ancienne version}
menuText F GameAdd "Enregistrer: Ajouter nouvelle partie..." 13 \
  {Enregistrer cette partie en tant que nouvelle partie dans la base}
menuText F GameDeepest "Identifier ouverture" 11 \
  {Trouver la partie la plus proche dans la nomenclature ECO}
menuText F GameGotoMove "Coup numéro..." 6 \
  {Aller au coup spécifié dans la partie en cours}
menuText F GameNovelty "Trouver la nouveauté..." 7 \
  {Trouver le premier coup de la partie qui n'a pas été joué auparavant}

# Search menu:
menuText F Search "Rechercher" 0
menuText F SearchReset "Réinitialiser le filtre" 0 \
  {Remettre à zéro le filtre (inclusion de toutes les parties)}
menuText F SearchNegate "Inverser le filtre" 0 \
  {Inverser le filtre}
menuText F SearchCurrent "Position..." 0 \
  {Rechercher la position en cours}
menuText F SearchHeader "Entête..." 0 \
  {Rechercher par entête (joueur, tournoi, etc) information}
menuText F SearchMaterial "Motifs" 0 \
  {Rechercher des motifs ou un matériel particulier sur l'échiquier}
menuText F SearchUsing "En utilisant un fichier d'options..." 0 \
  {Rechercher en utilisant un fichier d'options de recherche}

# Windows menu:
menuText F Windows "Fenêtres" 2
menuText F WindowsComment "Éditeur de commentaires" 0 \
  {Ouvrir/fermer l'éditeur de commentaires}
menuText F WindowsGList "Liste des parties" 0 \
  {Ouvrir/fermer la liste des parties}
menuText F WindowsPGN "Fenêtre PGN" 8 {Ouvrir/fermer la fenêtre PGN}
menuText F WindowsPList "Chercher un joueur" 2 {Ouvrir/fermer la recherche de joueur}
menuText F WindowsTmt "Recherche de tournois" 0 {Ouvrir/fermer la recherche de tournois}
menuText F WindowsSwitcher "Changer de base" 0 \
  {Ouvrir/Fermer l'outil de changement de base}
menuText F WindowsMaint "Fenêtre de Maintenance" 0 \
  {Ouvrir/Fermer la fenêtre de maintenance}
menuText F WindowsECO "Navigateur ECO" 0 {Ouvrir/fermer le navigateur ECO}
menuText F WindowsStats "Fenêtre de statistique" 11 \
  {Ouvrir/Fermer le filtre de statistiques}
menuText F WindowsTree "Fenêtre d'arbre" 10 \
  {Ouvrir/Fermer la fenêtre d'arbre}
menuText F WindowsTB "Fenêtre de tables de finales" 8 \
  {Ouvrir/Fermer la fenêtre de tables de finales}
menuText F WindowsBook "Bibliothèque d'ouvertures" 0 {Ouvrir/Fermer la bibliothèque d'ouverture}
menuText F WindowsCorrChess "Jeu par correspondance" 0 {Ouvrir/Fermer la fenêtre de jeu par correspondance}

# Tools menu:
menuText F Tools "Outils" 2
menuText F ToolsAnalysis "Moteur d'analyse..." 9 \
  {Démarrer/Arrêter un moteur d'analyses}
menuText F ToolsAnalysis2 "Moteur d'analyse #2..." 18 \
  {Démarrer/Arrêter un moteur d'analyses}
menuText F ToolsCross "Classement du tournoi" 0 \
  {Montrer le classement du tournoi}
menuText F ToolsEmail "Gestion des messages" 0 \
  {Ouvrir/Fermer la fenêtre de gestion des messages électroniques}
menuText F ToolsFilterGraph "Graphique de filtre" 7 {Ouvrir/Fermer la fenêtre du graphique de filtre}
menuText F ToolsAbsFilterGraph "Graphique de filtre absolu" 7 {Ouvrir/Fermer la fenêtre du graphique de filtre absolu}
menuText F ToolsOpReport "Rapport d'ouverture" 0 {Générer un rapport d'ouvertures à partir de la position courante}
menuText F ToolsOpenBaseAsTree "Ouvrir base dans arbre" 0   {Ouvrir une base dans la fenêtre d'arbre}
menuText F ToolsOpenRecentBaseAsTree "Ouvrir base récente dans arbre" 0   {Ouvrir une base récente dans la fenêtre d'arbre}
menuText F ToolsTracker "Suivi de pièce"  0 {Ouvrir la fenêtre de suivi de pièce}
menuText F ToolsTraining "Entrainement"  0 {Entrainement (tactique, ouvertures, ...) }
menuText F ToolsTacticalGame "Partie tactique"  0 {Jouer une partie tactique}
menuText F ToolsSeriousGame "Partie sérieuse"  0 {Jouer une partie sans handicap}
menuText F ToolsTrainOpenings "Ouvertures"  0 {Entrainement sur un répertoire}
menuText F ToolsTrainReviewGame "Revoir partie"  0 {Deviner les coups joués dans la partie}
menuText F ToolsTrainTactics "Tactique"  0 {Résoudre des problèmes tactiques}
menuText F ToolsTrainCalvar "Calcul de variantes"  0 {Entrainement au calcul de variantes}
menuText F ToolsTrainFindBestMove "Trouver le meilleur coup"  0 {Trouver le meilleur coup}
menuText F ToolsTrainFics "Jouer sur internet"  0 {Jouer sur freechess.org}
# ====== TODO To be translated ======
menuText F ToolsEngineTournament "Engine tournament"  0 {Start a tournament between chess engines}
menuText F ToolsBookTuning "Config. bibliothèque" 0 {Configuration fine d'une bibliothèque}
menuText F ToolsConnectHardware "Connecter matériel" 0 {Connecter un échiquier externe}
menuText F ToolsConnectHardwareConfigure "Configurer..." 0 {Configurer un échiquier externe et connection}
menuText F ToolsConnectHardwareNovagCitrineConnect "Connecter Novag Citrine" 0 {Connecter Novag Citrine}
menuText F ToolsConnectHardwareInputEngineConnect "Connecter entrée" 0 {Connecter un moteur en entrée (p.e. DGT)}
menuText F ToolsPInfo "Information sur les joueurs"  0 \
  {Ouvrir/Mettre à jour la fenêtre d'information sur les joueurs}
menuText F ToolsPlayerReport "Rapport pour le joueur..." 3 \
  {Générer un rapport pour le joueur}
menuText F ToolsRating "Elo graphique" 0 \
  {Tracer un graphique du classement Elo des joueurs de cette partie}
menuText F ToolsScore "Score graphique" 0 {Montrer le graphique des scores}
menuText F ToolsExpCurrent "Écrire la partie en cours" 22 \
  {Écrire la partie en cours dans un fichier texte}
menuText F ToolsExpCurrentPGN "Dans un fichier PGN..." 16 \
  {Écrire la partie en cours dans un fichier PGN}
menuText F ToolsExpCurrentHTML "Dans un fichier HTML..." 16 \
  {Écrire la partie en cours dans un fichier HTML}
menuText F ToolsExpCurrentHTMLJS "Dans un fichier HTML et JavaScript..." 16 {Écrire la partie en cours dans un fichier HTML et JavaScript}  
menuText F ToolsExpCurrentLaTeX "Dans un fichier LaTeX..." 16 \
  {Écrire la partie en cours dans un fichier LaTeX}
menuText F ToolsExpFilter "Écrire le filtre " 2 \
  {Écrire le filtre dans un fichier texte}
menuText F ToolsExpFilterPGN "Dans un fichier PGN..." 16 \
  {Écrire le filtre dans un fichier PGN}
menuText F ToolsExpFilterHTML "Dans un fichier HTML..." 16 \
  {Écrire le filtre dans un fichier HTML}
menuText F ToolsExpFilterHTMLJS "Dans un fichier HTML et JavaScript..." 16 {Écrire le filtre dans un fichier HTML et JavaScript}  
menuText F ToolsExpFilterLaTeX "Dans un fichier LaTeX..." 16 \
  {Écrire le filtre dans un fichier LaTeX}
menuText F ToolsImportOne "Importer une partie en PGN..." 0 \
  {Importer une partie à partir d'un texte PGN}
menuText F ToolsImportFile "Importer un fichier en PGN..." 12 \
  {Importer des parties à partir d'un fichier PGN}
menuText F ToolsStartEngine1 "Démarrer moteur 1" 0  {Démarrer moteur 1}
menuText F ToolsStartEngine2 "Démarrer moteur 2" 0  {Démarrer moteur 2}
# ====== TODO To be translated ======
menuText F ToolsCaptureBoard "Capture Current Board..." 0  {Save the current board as an image.}
menuText F Play "Jouer" 0
menuText F CorrespondenceChess "Echecs par correspondance" 0 {eMail et Xfcc échecs par correspondance}
menuText F CCConfigure "Configurer..." 0 {Configurer outils externes et config générale}
# ====== TODO To be translated ======
menuText F CCConfigRelay "Configure observations..." 10 {Configure games to be observed}
menuText F CCOpenDB "Ouvrir base..." 0 {Ouvrir la base de jeu par correspondance par défaut}
menuText F CCRetrieve "Récupérer parties" 0 {Récupérer les parties via Xfcc}
menuText F CCInbox "Analyser boîte" 0 {Analyser tous les fichiers dans la boîte de réception de Scid}
menuText F CCSend "Envoyer coup" 0 {Envoyer votre coup via eMail ou outil externe (Xfcc)}
menuText F CCResign "Abandonner" 0 {Abandonner (pas par eMail)}
menuText F CCClaimDraw "Réclamer la nulle" 0 {Envoyer coup et réclamer nulle (pas par eMail)}
menuText F CCOfferDraw "Proposer la nulle" 0 {Envoyer coup et proposer nulle (pas par eMail)}
menuText F CCAcceptDraw "Accepter la nulle" 0 {Accepter la nulle (pas par eMail)}
menuText F CCNewMailGame "Nouvelle partie eMail..." 0 {Commencer une nouvelle partie par eMail}
menuText F CCMailMove "eMailer le coup..." 0 {Envoyer le coup par eMail à l'adversaire}
menuText F CCGamePage "Page partie..." 0 {Ouvrir la partie dans navigateur web}
menuText F CCEditCopy "Copier parties dans Clipbase" 0 {Copy the games as CSV list to clipbase}

# Options menu:
menuText F Options "Options" 0
menuText F OptionsBoard "Echiquier" 0 {Options d'aspect de l'échiquier}
menuText F OptionsBoardSize "Taille échiquier" 0 {Changer la taille de l'échiquier}
menuText F OptionsBoardPieces "Style des pièces" 6 {Changer le style des pièces}
menuText F OptionsBoardColors "Couleurs..." 0 {Changer les couleurs}
menuText F OptionsBoardGraphics "Images de cases..." 0 {Select textures for squares}
translate F OptionsBGW {Sélectionner les textures des cases}
translate F OptionsBoardGraphicsText {Sélection des images pour les cases blanches et noires:}
menuText F OptionsBoardNames "Mes noms de joueurs..." 0 {Editer mes noms de joueurs}
menuText F OptionsExport "Exportation" 0 {Changer les options d'exportation}
menuText F OptionsFonts "Polices" 0 {Changer les polices}
menuText F OptionsFontsRegular "Normales" 0 {Changer les polices normales}
menuText F OptionsFontsMenu "Menu" 0 {Changer la police des menus}
menuText F OptionsFontsSmall "Petites" 0 {Changer les petites polices}
menuText F OptionsFontsTiny "Minuscule" 0 {Change the tiny font}
menuText F OptionsFontsFixed "Fixe" 0 {Changer les polices de chasse fixe}
menuText F OptionsGInfo "Informations de la partie" 7 {Options d'information de la partie}
menuText F OptionsLanguage "Langue" 0 {Sélectionner le menu de choix des langues}
menuText F OptionsMovesTranslatePieces "Traduction des pièces" 0 {Convertit la première lettre des pièces}
menuText F OptionsMovesHighlightLastMove "Surbrillance dernier coup" 0 {Surbrillance du dernier coup}
menuText F OptionsMovesHighlightLastMoveDisplay "Afficher" 0 {Afficher la surbrillance du dernier coup}
menuText F OptionsMovesHighlightLastMoveWidth "Epaisseur" 0 {Epaisseur de la ligne}
menuText F OptionsMovesHighlightLastMoveColor "Couleur" 0 {Couleur de la ligne}
menuText F OptionsMovesHighlightLastMoveArrow "inclure Flèche" 0 {Include Arrow with Highlight}
menuText F OptionsMoves "Coups" 2 {Gestion des coups}
menuText F OptionsMovesAsk "Demander avant d'écraser les coups" 0 \
  {Demander avant d'écraser un coup existant}
menuText F OptionsMovesAnimate "Temps d'animation" 1 \
  {Fixe le temps utilisé pour l'animation des coups}
menuText F OptionsMovesDelay "Délai entre les coups" 3 \
  {Positionner le délai entre deux coups en mode automatique}
menuText F OptionsMovesCoord "Coordonnées entre les coups" 0 \
  {Accepter l'entrée des coups par coordonnées ("g1f3")}
menuText F OptionsMovesSuggest "Montrer les coups suggérés" 0 \
  {Activer/Désactiver le mode de suggestion de coup}
menuText F OptionsShowVarPopup "Montrer fenêtre des variantes" 0 {Affichage automatique des variantes}  
menuText F OptionsMovesSpace "Ajouter un espace après le numéro du coup" 0 {Espace après numéro du coup}  
menuText F OptionsMovesKey "Complétion clavier" 0 \
  {Activer/Désactiver le mode de complétion du clavier}
menuText F OptionsMovesShowVarArrows "Montrer flêches pour les variations" 0 {Montrer des flêches pour les variations existantes}
menuText F OptionsMovesGlossOfDanger "Couleur codée Gloss of Danger" 0 {Turn on/off color coded gloss of danger}
menuText F OptionsNumbers "Format numérique" 7 {Sélectionner le format des nombres}
menuText F OptionsStartup "Démarrage" 3 {Sélectionner les fenêtres à ouvrir au démarrage}
menuText F OptionsTheme "Apparence" 0 {Change l'apparence de l'interface}
menuText F OptionsWindows "Fenêtres" 0 {Options des fenêtres}
menuText F OptionsWindowsIconify "Mise en icone automatique" 5 \
  {Mettre toutes les fenêtres en icones quand la fenêtre principale est mise en icone}
menuText F OptionsWindowsRaise "Apparition automatique" 0 \
  {Faire apparaître certaines fenêtres (i.e. barres de progression) à chaque fois qu'elles sont obscurcies}
menuText F OptionsSounds "Sons..." 2 {Configurer l'annonce des sonore des coups}
menuText F OptionsWindowsDock "Fenêtres groupées" 0 {Fenêtres groupées (nécessite un redémarrage)}
menuText F OptionsWindowsSaveLayout "Enregistrer disposition" 0 {Enregistrer disposition}
menuText F OptionsWindowsRestoreLayout "Remettre disposition" 0 {Remettre disposition}
menuText F OptionsWindowsShowGameInfo "Montrer le panneau d'info" 0 {Montrer le panneau d'info}
menuText F OptionsWindowsAutoLoadLayout "Chargement auto 1ère disposition" 0 {Chargement auto de la première disposition au démarrage}
menuText F OptionsToolbar "Barre d'outils de la fenêtre principale" 12 \
  {Montrer/Cacher dans la barre d'outils de la fenêtre principale}
menuText F OptionsECO "Charger le fichier ECO..." 20 \
  {Charger un fichier au format ECO}
menuText F OptionsSpell "Charger le fichier d'orthographe..." 25 \
  {Charger un fichier de correction orthographique scid}
menuText F OptionsTable "Répertoire des tables de finales TB..." 0 \
  {Sélectionner un répertoire de fichiers TB, tous les fichiers de ce répertoire seront utilisés}
menuText F OptionsRecent "Fichiers récents..." 0 \
  {Changer le nombre de fichiers récents affichés dans le menu Fichier}
menuText F OptionsBooksDir "Répertoire des bibliothèques..." 0 {Répertoire des bibliothèques d'ouverture}
menuText F OptionsTacticsBasesDir "Répertoire des bases d'entrainement..." 0 {Répertoire des bases pour l'entrainement tactique}
menuText F OptionsPhotosDir "Répertoire des images..." 0 {Répertoire des bases pour l'images}
# ====== TODO To be translated ======
menuText F OptionsThemeDir "Load Theme(s)..."  0 { Load a GUI theme package file }
menuText F OptionsSave "Sauver les options" 0 "Sauver les options dans le fichier $::optionsFile"
menuText F OptionsAutoSave "Sauvegarde automatique des options" 0 \
  {Sauvegarder automatiquement toutes les options en quittant Scid}
# ====== TODO To be translated ======
menuText F OptionsMenuColor "Setup Menu Colors..." 0 { }
# ====== TODO To be translated ======
translate F MenuColorForeground "Textcolor"
# ====== TODO To be translated ======
translate F MenuColorBackground "Background"
# ====== TODO To be translated ======
translate F MenuColorSelect "Select"

# Help menu:
menuText F Help "Aide" 0
menuText F HelpContents "Contenu" 0 {Montrer la page du contenu de l'aide}
menuText F HelpIndex "Index" 0 {Afficher la table des matières}
menuText F HelpGuide "Aide Rapide" 5 {Montrer la page d'aide rapide}
menuText F HelpHints "Astuces" 0 {Afficher les trucs et astuces}
menuText F HelpContact "Contact" 0 {Afficher les noms des contacts}
menuText F HelpTip "Astuce du jour" 0 {Afficher une astuce Scid}
menuText F HelpStartup "Fenêtre de démarrage" 0 {Afficher la fenêtre de démarrage}
menuText F HelpAbout "A propos de Scid" 2 {Information au sujet de Scid}

# Game info box popup menu:
menuText F GInfoHideNext "Cacher le coup suivant" 0
menuText F GInfoMaterial "Montrer les valeurs de matériel" 0
menuText F GInfoFEN "Montrer la notation FEN" 5
menuText F GInfoMarks "Montrer les cases colorées et les flèches" 5
menuText F GInfoWrap "Découper les longues lignes" 0
menuText F GInfoFullComment "Montrer tous les commentaires" 10
menuText F GInfoPhotos "Montrer les Photos" 5
menuText F GInfoTBNothing "Tables de finales: Rien" 12
menuText F GInfoTBResult "Tables de finales: Seulement le résultat" 12
menuText F GInfoTBAll "Tables de finales: résultat et meilleurs coups" 19
menuText F GInfoDelete "(Récupérer)Effacer cette partie" 4
menuText F GInfoMark "(Dé)Marquer cette partie" 4
menuText F GInfoInformant "Configurer les valeurs de notation" 0

# General buttons:
translate F Back {Retour}
translate F Browse {Parcourir}
translate F Cancel {Annuler}
translate F Continue {Continuer}
translate F Clear {Effacer}
translate F Close {Fermer}
translate F Contents {Contenu}
translate F Defaults {Par défaut}
translate F Delete {Éliminer}
translate F Graph {Graphique}
translate F Help {Aide}
translate F Import {Importer}
translate F Index {Index}
translate F LoadGame {Charger partie}
translate F BrowseGame {Explorer la partie dans une fenêtre séparée}
translate F MergeGame {Fusionner la partie comme variante}
translate F MergeGames {Fusionner les parties}
translate F Preview {Prévisualiser}
translate F Revert {Revenir}
translate F Save {Enregistrer}
translate F Search {Rechercher}
translate F Stop {Arrêter}
translate F Store {Enregistrer}
translate F Update {Mettre à jour}
translate F ChangeOrient {Changer l'orientation de la fenêtre}
translate F ShowIcons {Montrer les icones}
translate F None {Aucun}
translate F First {Premier}
translate F Current {En cours}
translate F Last {Dernier}

# General messages:
translate F game {partie}
translate F games {parties}
translate F move {coup}
translate F moves {coups}
translate F all {tout}
translate F Yes {Oui}
translate F No {Non}
translate F Both {Les deux}
translate F King {Roi}
translate F Queen {Dame}
translate F Rook {Tour}
translate F Bishop {Fou}
translate F Knight {Cavalier}
translate F Pawn {Pion}
translate F White {Blancs}
translate F Black {Noirs}
translate F Player {Joueur}
translate F Rating {Classement ELO}
translate F RatingDiff {Différence de classement ELO (Blancs - Noirs)}
translate F AverageRating {Classement moyen}
translate F Event {Événement}
translate F Site {Lieux}
translate F Country {Pays}
translate F IgnoreColors {Ignorer les couleurs}
translate F Date {Date}
translate F EventDate {Événement date}
translate F Decade {Décennie}
translate F Year {Année}
translate F Month {Mois}
translate F Months {Janvier Février Mars Avril Mai Juin Juillet Août Septembre Octobre Novembre Décembre}
translate F Days {Dim Lun Mar Mer Jeu Ven Sam}
translate F YearToToday {-1A}
# ====== TODO To be translated ======
translate F YearToTodayTooltip {Set date from 1 year back to today}
translate F Result {Résultat}
translate F Round {Ronde}
translate F Length {Longueur}
translate F ECOCode {code ECO}
translate F ECO {ECO}
translate F Deleted {Éliminé}
translate F SearchResults {Résultats de la recherche}
translate F OpeningTheDatabase {Ouverture de la base}
translate F Database {Base}
translate F Filter {Filtre}
translate F noGames {pas de parties}
translate F allGames {toutes les parties}
translate F empty {vide}
translate F clipbase {presse-papier}
translate F score {score}
translate F StartPos {Position de départ}
translate F Total {Total}
translate F readonly {lecture seule}

# Standard error messages:
translate F ErrNotOpen {Ceci n'est pas une base ouverte.}
translate F ErrReadOnly {Cette base est en lecture seule; elle ne peut être modifiée.}
translate F ErrSearchInterrupted {La recherche a été interrompue; les résultats sont incomplets.}

# Game information:
translate F twin {doublon}
translate F deleted {éliminé}
translate F comment {commentaire}
translate F hidden {caché}
translate F LastMove {Dernier coup}
translate F NextMove {Coup suivant}
translate F GameStart {Début de partie}
translate F LineStart {Début de ligne}
translate F GameEnd {Fin de partie}
translate F LineEnd {Fin de ligne}

# Player information:
translate F PInfoAll {Résultats pour <b>toutes</b> les parties}
translate F PInfoFilter {Résultats pour les parties <b>filtrées</b>}
translate F PInfoAgainst {Résultats contre}
translate F PInfoMostWhite {Ouvertures les plus fréquentes avec les blancs}
translate F PInfoMostBlack {Ouvertures les plus fréquentes avec les noirs}
translate F PInfoRating {Historique du classement}
translate F PInfoBio {Biographie}
translate F PInfoEditRatings {Editer les Classements}

# Tablebase information:
translate F Draw {Nulle}
translate F stalemate {pat}
translate F withAllMoves {avec tous les coups}
translate F withAllButOneMove {avec tous les coups sauf le dernier}
translate F with {avec}
translate F only {seulement}
translate F lose {perte}
translate F loses {pertes}
translate F allOthersLose {toutes les autres pertes}
translate F matesIn {mat en}
translate F hasCheckmated {a maté}
translate F longest {le plus long}
translate F WinningMoves {Coups gagnants}
translate F DrawingMoves {Coups faisant nulle}
translate F LosingMoves {Coups perdants}
translate F UnknownMoves {Coups dont le résultat est inconnu}
# ====== TODO To be translated ======
translate F SideLongest {Side    Longest    %     %     %\n}
# ====== TODO To be translated ======
translate F toNoveMate {to move   mate    Win  Draw  Loss\n}
# ====== TODO To be translated ======
translate F NoSummary {\nNo summary for this tablebase.}
# ====== TODO To be translated ======
translate F MutualZugzwang {Mutual zugzwangs: }
# ====== TODO To be translated ======
translate F SelectetZugzwang {\nSelected zugzwang positions:}
# ====== TODO To be translated ======
translate F WdrawBloss {White draws, Black loses:}
# ====== TODO To be translated ======
translate F BdrawWloss {Black draws, White loses:}
# ====== TODO To be translated ======
translate F AllLoss {" Whoever moves loses:     " }

# Tip of the day:
translate F Tip {Conseil}
translate F TipAtStartup {Conseil au démarrage}

# Tree window menus:
menuText F TreeFile "Fichier" 0
menuText F TreeFileFillWithBase "Remplir cache avec base" 0 {Remplir le cache avec toutes les parties de la base courante}
menuText F TreeFileFillWithGame "Remplir cache avec partie" 0 {Remplir le cache avec la partie de la base courante}
menuText F TreeFileSetCacheSize "Taille du cache" 0 {Taille du cache}
menuText F TreeFileCacheInfo "Info cache" 0 {Afficher information sur l'utilisation du cache}
menuText F TreeFileSave "Sauver le cache" 0
menuText F TreeFileFill "Remplir le cache" 0
menuText F TreeFileBest "Liste des meilleures parties" 0 {Montrer la liste des meilleures parties}
menuText F TreeFileGraph "Graphique" 0 {Graphique de l'arbre}
menuText F TreeFileCopy "Copier l'arbre dans le presse-papiers" 0
menuText F TreeFileClose "Fermer la fenêtre d'arbre" 0
menuText F TreeMask "Masque" 0
menuText F TreeMaskNew "Nouveau" 0 {Nouveau masque}
menuText F TreeMaskOpen "Ouvrir" 0 {Ouvrir masque}
menuText F TreeMaskOpenRecent "Ouvrir récent" 0 {Ouvrir un masque récent}
menuText F TreeMaskSave "Sauver" 0 {Sauver masque}
menuText F TreeMaskClose "Fermer" 0 {Fermer masque}
menuText F TreeMaskFillWithGame "Remplir avec partie" 0 {Remplir le masque avec partie}
menuText F TreeMaskFillWithBase "Remplir avec base" 0 {Remplir le masque avec les parties de la base}
menuText F TreeMaskInfo "Info" 0 {Statistiques du masque}
menuText F TreeMaskDisplay "Afficher l'arbre" 0 {Affichage des données du masque sous la forme d'un arbre}
menuText F TreeMaskSearch "Chercher" 0 {Chercher dans le masque courant}
menuText F TreeSort "Trier" 0
menuText F TreeSortAlpha "Alphabétique" 0
menuText F TreeSortECO "code ECO" 0
menuText F TreeSortFreq "Fréquence" 0
menuText F TreeSortScore "Score" 0
menuText F TreeOpt "Options" 0
menuText F TreeOptSlowmode "Mode lent" 0 {Mode lent pour rafraichissement (précis)}
menuText F TreeOptFastmode "Mode rapide" 0 {Mode rapide pour rafraichissement (pas de transpositions)}
menuText F TreeOptFastAndSlowmode "Mode rapide puis lent" 0 {Mode rapide puis lent pour rafraichissement}
menuText F TreeOptStartStop "Rafraîchissement auto" 0 {Rafraîchissement automatique de la fenêtre}
menuText F TreeOptLock "Verrouille" 0 {Dé/verrouiller l'arbre à la base en cours}
menuText F TreeOptTraining "Entraînement" 0 {Démarrer/Arrêter l'arbre du mode d'entraînement}
menuText F TreeOptAutosave "Sauver le cache automatiquement" 0
menuText F TreeHelp "Aide" 0
menuText F TreeHelpTree "Aide Arbre" 0
menuText F TreeHelpIndex "Index" 0
translate F SaveCache {Sauver le cache}
translate F Training {Entraînement}
translate F LockTree {Verrouiller}
translate F TreeLocked {verrouillé}
translate F TreeBest {Meilleur}
translate F TreeBestGames {Arbre des meilleures parties}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate F TreeTitleRow \
  {    Coup   ECO        Fréquence   Score EloMoy Perf AnnéeMoy %Nulle}
translate F TreeTotal {TOTAL}
translate F DoYouWantToSaveFirst {voulez-vous d'abord sauvegarder}
translate F AddToMask {Ajouter au masque}
translate F RemoveFromMask {Enlever du masque}
translate F AddThisMoveToMask {Ajouter ce coup au masque}
translate F SearchMask {Recherche dans masque}
translate F DisplayMask {Affichage du masque}
translate F Nag {Code Nag}
translate F Marker {Marqueur}
translate F Include {Inclure}
translate F Exclude {Exclure}
translate F MainLine {Ligne principale}
translate F Bookmark {Signet}
translate F NewLine {Nouvelle ligne}
translate F ToBeVerified {A vérifier}
translate F ToTrain {S'entrainer}
translate F Dubious {Douteux}
translate F ToRemove {A supprimer}
translate F NoMarker {Aucun marqueur}
translate F ColorMarker {Couleur}
translate F WhiteMark {Blanc}
translate F GreenMark {Vert}
translate F YellowMark {Jaune}
translate F BlueMark {Bleu}
translate F RedMark {Rouge}
translate F CommentMove {Annoter coup}
translate F CommentPosition {Annoter position}
translate F AddMoveToMaskFirst {Ajoutez d'abord le coup au masque}
translate F OpenAMaskFileFirst {Ouvrez d'abord un masque}
translate F Positions {Positions}
translate F Moves {Coups}

# Finder window:
menuText F FinderFile "Fichier" 0
menuText F FinderFileSubdirs "Rechercher dans les sous répertoires" 0
menuText F FinderFileClose "Fermer l'explorateur de fichiers" 0
menuText F FinderSort "Trier" 0
menuText F FinderSortType "Type" 0
menuText F FinderSortSize "Taille" 0
menuText F FinderSortMod "Modifié" 0
menuText F FinderSortName "Nom" 0
menuText F FinderSortPath "Chemin" 0
menuText F FinderTypes "Types" 0
menuText F FinderTypesScid "Bases Scid" 0
menuText F FinderTypesOld "Bases Scid à l'ancien format" 0
menuText F FinderTypesPGN "fichiers PGN" 0
menuText F FinderTypesEPD "fichiers EPD (théorie)" 0
menuText F FinderTypesRep "fichiers des répertoires" 0
menuText F FinderHelp "Aide" 0
menuText F FinderHelpFinder "Aide de l'explorateur de fichiers" 0
menuText F FinderHelpIndex "Index" 0
translate F FileFinder {Explorateur de fichiers}
translate F FinderDir {Répertoire}
translate F FinderDirs {Répertoires}
translate F FinderFiles {Fichiers}
translate F FinderUpDir {répertoire précédent}
translate F FinderCtxOpen {Ouvrir}
translate F FinderCtxBackup {Sauvegarder}
translate F FinderCtxCopy {Copier}
translate F FinderCtxMove {Déplacer}
translate F FinderCtxDelete {Supprimer}

# Player finder:
menuText F PListFile "Fichier" 0
menuText F PListFileUpdate "Mettre à jour" 0
menuText F PListFileClose "Fermer la recherche de joueur" 0
menuText F PListSort "Trier" 0
menuText F PListSortName "Nom" 0
menuText F PListSortElo "Elo" 0
menuText F PListSortGames "Parties" 0
menuText F PListSortOldest "Les plus vieux" 0
menuText F PListSortNewest "Les plus récents" 0

# Tournament finder:
menuText F TmtFile "Fichier" 0
menuText F TmtFileUpdate "Mettre à jour" 0
menuText F TmtFileClose "Fermer l'explorateur de tournois" 0
menuText F TmtSort "Trier" 0
menuText F TmtSortDate "Date" 0
menuText F TmtSortPlayers "Joueurs" 0
menuText F TmtSortGames "Parties" 0
menuText F TmtSortElo "Elo" 0
menuText F TmtSortSite "Lieux" 0
menuText F TmtSortEvent "Événement" 1
menuText F TmtSortWinner "Vainqueur" 0
translate F TmtLimit "Limite de liste"
translate F TmtMeanElo "Moyenne ELO la plus basse"
translate F TmtNone "Aucun tournoi correspondant n'a été trouvé."

# Graph windows:
menuText F GraphFile "Fichier" 0
menuText F GraphFileColor "Sauver comme Postscript en couleurs..." 27
menuText F GraphFileGrey "Sauver comme Postscript en niveaux de gris..." 27
menuText F GraphFileClose "Fermer la fenêtre" 0
menuText F GraphOptions "Options" 0
menuText F GraphOptionsWhite "Blancs" 0
menuText F GraphOptionsBlack "Noirs" 0
menuText F GraphOptionsBoth "Les deux" 4
menuText F GraphOptionsPInfo "Informations joueurs" 0
translate F GraphFilterTitle "Graphique de filtre: fréquence pour 1000 parties"
translate F GraphAbsFilterTitle "Graphique de filtre: fréquence des parties"
translate F ConfigureFilter {Configurer l'axe des X par année, classement et coups}
translate F FilterEstimate "Estimer"
translate F TitleFilterGraph "Scid: Graphe de filtre"

# Analysis window:
translate F AddVariation {Ajouter une variante}
translate F AddAllVariations {Ajouter toutes les variantes}
translate F AddMove {Ajouter le coup}
translate F Annotate {Annotation}
translate F ShowAnalysisBoard {Montrer échiquier d'analyse}
translate F ShowInfo {Montrer infos moteur}
translate F FinishGame {Continuer la partie}
translate F StopEngine {Arrêter le moteur}
translate F StartEngine {Démarrer le moteur}
translate F LockEngine {Verrouiller moteur à la position actuelle}
translate F AnalysisCommand {Commande d'analyse}
translate F PreviousChoices {Choix précédents}
translate F AnnotateTime {Temps en secondes par deux coups}
translate F AnnotateWhich {Ajouter des variantes}
translate F AnnotateAll {Pour les coups des deux cotés}
translate F AnnotateAllMoves {Annoter tous les coups}
translate F AnnotateWhite {Pour les coups des blancs seulement}
translate F AnnotateBlack {Pour les coups des noirs seulement}
translate F AnnotateBlundersOnly {Quand le coup est une erreur}
translate F AnnotateBlundersOnlyScoreChange {Coup faible, le score varie de/à: }
translate F BlundersThreshold {Seuil de l'erreur}
# TODO: Translate
translate F ScoreAllMoves {Valider tous les coups}
translate F LowPriority {Priorité processeur basse}
translate F ClickHereToSeeMoves {Cliquer ici pour afficher les coups}
translate F ConfigureInformant {Configurer les valeurs des notations}
translate F Informant!? {Coup intéressant}
translate F Informant? {Coup faible}
translate F Informant?? {Mauvais coup}
translate F Informant?! {Coup douteux}
translate F Informant+= {Les blancs ont un léger avantage}
translate F Informant+/- {Les blancs ont l'avantage}
translate F Informant+- {Les blancs ont un avantage décisif}
translate F Informant++- {La partie est gagnée}

# Book window
translate F Book {Bibliothèque}
translate F OtherBookMoves {Bibliothèque de l'adversaire}
translate F OtherBookMovesTooltip {Coups pour lesquels l'adversaire a une réponse}

# Analysis Engine open dialog:
translate F EngineList {Liste des moteurs d'analyse}
translate F EngineName {Nom}
translate F EngineCmd {Commande}
translate F EngineArgs {Paramètres}
translate F EngineDir {Répertoire}
translate F EngineElo {Elo}
translate F EngineTime {Date}
translate F EngineNew {Nouvelle}
translate F EngineEdit {Éditer}
translate F EngineRequired {Les champs en gras sont requis; les autres sont optionnels}

# Stats window menus:
menuText F StatsFile "Fichier" 0
menuText F StatsFilePrint "Écrire dans fichier..." 0
menuText F StatsFileClose "Fermer la fenêtre" 0
menuText F StatsOpt "Options" 0

# PGN window menus:
menuText F PgnFile "Fichier" 0
menuText F PgnFileCopy "Copier la partie dans le Presse-papier" 0
menuText F PgnFilePrint "Écrire dans fichier..." 0
menuText F PgnFileClose "Fermer la fenêtre PGN" 0
menuText F PgnOpt "Affichage" 0
menuText F PgnOptColor "Couleur d'affichage" 0
menuText F PgnOptShort "Entête court (3-lignes)" 0
menuText F PgnOptSymbols "Annotations symboliques" 0
menuText F PgnOptIndentC "Indentation des commentaires" 0
menuText F PgnOptIndentV "Indentation des variantes" 16
menuText F PgnOptColumn "Style en colonne (un coup par ligne)" 1
menuText F PgnOptSpace "Espace après numéro des coups" 0
menuText F PgnOptStripMarks "Enlever les codes de flèches et de coloration de cases" 1
menuText F PgnOptBoldMainLine "Mettre en gras les coups de la ligne principale" 4
menuText F PgnColor "Couleur" 0
menuText F PgnColorHeader "Entête..." 0
menuText F PgnColorAnno "Annotations..." 0
menuText F PgnColorComments "Commentaires..." 0
menuText F PgnColorVars "Variantes..." 0
menuText F PgnColorBackground "Couleur du fond..." 11
menuText F PgnColorMain "Main line..." 0
menuText F PgnColorCurrent "Dernier coup..." 1
menuText F PgnHelp "Aide" 0
menuText F PgnHelpPgn "Aide PGN" 0
menuText F PgnHelpIndex "Index" 0
translate F PgnWindowTitle {Notation - partie %u}

# Crosstable window menus:
menuText F CrosstabFile "Fichier" 0
menuText F CrosstabFileText "Écrire dans un fichier texte..." 23
menuText F CrosstabFileHtml "Écrire dans un fichier HTML..." 23
menuText F CrosstabFileLaTeX "Écrire dans un fichier LaTeX..." 23
menuText F CrosstabFileClose "Fermer fenêtre tableau" 0
menuText F CrosstabEdit "Éditer" 0
menuText F CrosstabEditEvent "Événement" 0
menuText F CrosstabEditSite "Lieux" 0
menuText F CrosstabEditDate "Date" 0
menuText F CrosstabOpt "Affichage" 0
menuText F CrosstabOptAll "Toutes rondes" 0
menuText F CrosstabOptSwiss "Suisse" 0
menuText F CrosstabOptKnockout "KO" 0
menuText F CrosstabOptAuto "Auto" 0
menuText F CrosstabOptAges "Ages en années" 8
menuText F CrosstabOptNats "Nationalités" 0
menuText F CrosstabOptRatings "Classements" 0
menuText F CrosstabOptTitles "Titres" 0
menuText F CrosstabOptBreaks "Scores du départage" 4
menuText F CrosstabOptDeleted "Inclure les parties effacées" 8
menuText F CrosstabOptColors "Couleurs (système suisse uniquement)" 1
menuText F CrosstabOptColumnNumbers "Colonnes numérotées (Toutes rondes seulement)" 2
menuText F CrosstabOptGroup "Scores du groupe" 0
menuText F CrosstabSort "Trier" 0
menuText F CrosstabSortName "Nom" 0
menuText F CrosstabSortRating "Elo" 0
menuText F CrosstabSortScore "Score" 0
menuText F CrosstabColor "Couleur" 0
menuText F CrosstabColorPlain "Texte normal" 0
menuText F CrosstabColorHyper "Hypertexte" 0
menuText F CrosstabHelp "Aide" 0
menuText F CrosstabHelpCross "Aide tableau" 0
menuText F CrosstabHelpIndex "Index" 0
translate F SetFilter {Activer le filtre}
translate F AddToFilter {Ajouter au filtre}
translate F Swiss {Suisse}
translate F Category {Catégorie}

# Opening report window menus:
menuText F OprepFile "Fichier" 0
menuText F OprepFileText "Écrire dans un fichier texte..." 23
menuText F OprepFileHtml "Écrire dans un fichier HTML..." 23
menuText F OprepFileLaTeX "Écrire dans un fichier LaTeX..." 23
menuText F OprepFileOptions "Options..." 0
menuText F OprepFileClose "Fermer la fenêtre du rapport" 0
menuText F OprepFavorites "Favoris" 1
menuText F OprepFavoritesAdd "Ajouter au rapport..." 0
menuText F OprepFavoritesEdit "Editer les favoris de rapport..." 0
menuText F OprepFavoritesGenerate "Générer les rapports..." 0

menuText F OprepHelp "Aide" 0
menuText F OprepHelpReport "Aide du rapport" 0
menuText F OprepHelpIndex "Index" 0

# Header search:
translate F HeaderSearch {Rechercher Entête}
translate F EndSideToMove {Côté devant jouer à la fin de la partie}
translate F GamesWithNoECO {Partie sans code ECO?}
translate F GameLength {Longueur de la partie}
translate F FindGamesWith {Chercher les parties avec}
translate F StdStart {Pos. départ non standard}
translate F Promotions {Promotions}
translate F Comments {Commentaires}
translate F Variations {Variantes}
translate F Annotations {Annotations}
translate F DeleteFlag {Marquées supprimées}
translate F WhiteOpFlag {Ouverture des blancs}
translate F BlackOpFlag {Ouverture des noirs}
translate F MiddlegameFlag {Milieu de partie}
translate F EndgameFlag {Finale}
translate F NoveltyFlag {Nouveauté}
translate F PawnFlag {Structure de pions}
translate F TacticsFlag {Tactiques}
translate F QsideFlag {Jeu à l'aile dame}
translate F KsideFlag {Jeu à l'aile roi}
translate F BrilliancyFlag {Spectaculaire}
translate F BlunderFlag {Gaffe}
translate F UserFlag {Utilisateur}
translate F PgnContains {PGN contenant du texte}
# ====== TODO To be translated ======
translate F Annotator {Annotator}
# ====== TODO To be translated ======
translate F Cmnts {Annotated games only}

# Game list window:
translate F GlistNumber {Numéro}
translate F GlistWhite {Blancs}
translate F GlistBlack {Noirs}
translate F GlistWElo {B-Elo}
translate F GlistBElo {N-Elo}
translate F GlistEvent {Événement}
translate F GlistSite {Lieux}
translate F GlistRound {Ronde}
translate F GlistDate {Date}
translate F GlistYear {Année}
translate F GlistEDate {Événement-Date}
translate F GlistResult {Résultat}
translate F GlistLength {Longueur}
translate F GlistCountry {Pays}
translate F GlistECO {ECO}
translate F GlistOpening {Ouverture}
translate F GlistEndMaterial {Matériel final}
translate F GlistDeleted {Effacé}
translate F GlistFlags {Drapeaux}
translate F GlistVars {Variantes}
translate F GlistComments {Commentaires}
translate F GlistAnnos {Annotations}
translate F GlistStart {Départ}
translate F GlistGameNumber {Partie numéro}
# ====== TODO To be translated ======
translate F GlistAverageElo {Average Elo}
# ====== TODO To be translated ======
translate F GlistRating {Rating}
translate F GlistFindText {Rechercher texte}
translate F GlistMoveField {Coup}
translate F GlistEditField {Configurer}
translate F GlistAddField {Ajouter}
translate F GlistDeleteField {Enlever}
translate F GlistWidth {Largeur}
translate F GlistAlign {Aligner}
# ====== TODO To be translated ======
translate F GlistAlignL {Align: left}
# ====== TODO To be translated ======
translate F GlistAlignR {Align: right}
# ====== TODO To be translated ======
translate F GlistAlignC {Align: center}
translate F GlistColor {Couleur}
translate F GlistSep {Séparateur}
# ====== TODO To be translated ======
translate F GlistCurrentSep {-- Current --}
# ====== TODO To be translated ======
translate F GlistNewSort {New}
# ====== TODO To be translated ======
translate F GlistAddToSort {Add}
# ====== TODO To be translated ======
translate F GsortSort {Sort...}
# ====== TODO To be translated ======
translate F GsortDate {Date}
# ====== TODO To be translated ======
translate F GsortYear {Year}
# ====== TODO To be translated ======
translate F GsortEvent {Event}
# ====== TODO To be translated ======
translate F GsortSite {Site}
# ====== TODO To be translated ======
translate F GsortRound {Round}
# ====== TODO To be translated ======
translate F GsortWhiteName {White Name}
# ====== TODO To be translated ======
translate F GsortBlackName {Black Name}
# ====== TODO To be translated ======
translate F GsortECO {ECO}
# ====== TODO To be translated ======
translate F GsortResult {Result}
# ====== TODO To be translated ======
translate F GsortMoveCount {Move Count}
# ====== TODO To be translated ======
translate F GsortAverageElo {Average Elo}
# ====== TODO To be translated ======
translate F GsortCountry {Country}
# ====== TODO To be translated ======
translate F GsortDeleted {Deleted}
# ====== TODO To be translated ======
translate F GsortEventDate {Event Date}
# ====== TODO To be translated ======
translate F GsortWhiteElo {White Elo}
# ====== TODO To be translated ======
translate F GsortBlackElo {Black Elo}
# ====== TODO To be translated ======
translate F GsortComments {Comments}
# ====== TODO To be translated ======
translate F GsortVariations {Variations}
# ====== TODO To be translated ======
translate F GsortNAGs {NAGs}
# ====== TODO To be translated ======
translate F GsortAscending {Ascending}
# ====== TODO To be translated ======
translate F GsortDescending {Descending}
# ====== TODO To be translated ======
translate F GsortAdd {Add}
# ====== TODO To be translated ======
translate F GsortStore {Store}
# ====== TODO To be translated ======
translate F GsortLoad {Load}

# menu shown with right mouse button down on game list.
translate F GlistRemoveThisGameFromFilter  {Enlever cette partie du filtre}
translate F GlistRemoveGameAndAboveFromFilter  {Enlever cette partie (et celles au-dessus) du filtre}
translate F GlistRemoveGameAndBelowFromFilter  {Enlever cette partie (et celles en-dessous) du filtre}
translate F GlistDeleteGame {(Dés-)effacer cette partie} 
translate F GlistDeleteAllGames {Effacer toutes les parties du filtre} 
translate F GlistUndeleteAllGames {Dés-effacer toutes les parties du filtre} 
translate F GlistMergeGameInBase {Fusionner la partie dans une autre base} 

# Maintenance window:
translate F DatabaseName {Nom de base:}
translate F TypeIcon {Type icône:}
translate F NumOfGames {Parties:}
translate F NumDeletedGames {Parties supprimées:}
translate F NumFilterGames {Parties dans le filtre:}
translate F YearRange {Années:}
translate F RatingRange {Classements:}
translate F Description {Description}
translate F Flag {Drapeau}
translate F CustomFlags {Drapeaux personnalisés}
translate F DeleteCurrent {Effacer la partie courante}
translate F DeleteFilter {Effacer le filtre de parties}
translate F DeleteAll {Effacer toutes les parties}
translate F UndeleteCurrent {Récupérer la partie en cours}
translate F UndeleteFilter {Récupérer les parties filtrées}
translate F UndeleteAll {Récupérer toutes les parties}
translate F DeleteTwins {Effacer les parties en doublon}
translate F MarkCurrent {Sélectionner la partie en cours}
translate F MarkFilter {Sélectionner les parties filtrées}
translate F MarkAll {Sélectionner toutes les parties}
translate F UnmarkCurrent {Désélectionner la partie en cours}
translate F UnmarkFilter {Désélectionner les parties filtrées}
translate F UnmarkAll {Désélectionner toutes les parties}
translate F Spellchecking {Vérification orthographique}
translate F Players {Joueurs}
translate F Events {Événements}
translate F Sites {Lieux}
translate F Rounds {Rondes}
translate F DatabaseOps {Opérations sur la base}
translate F ReclassifyGames {ECO-Classifier les parties...}
translate F CompactDatabase {Compacter la base}
translate F SortDatabase {Trier la base}
translate F AddEloRatings {Ajouter les classements Elo}
translate F AutoloadGame {Chargement automatique du numéro de partie}
translate F StripTags {Enlever les marqueurs PGN}
translate F StripTag {Enlever les marqueurs}
translate F Cleaner {Nettoyer}
translate F CleanerHelp {
Le Nettoyeur Scid va réaliser pour la base en cours toutes les actions de maintenance que vous avez sélectionné à partir de la liste ci-dessous.

Les réglages en cours de la classification ECO et les dialogues d'effacement des jumeaux vont s'appliquer si vous avez sélectionné ces fonctions.
}
translate F CleanerConfirm {
Une fois que le nettoyage est commencé, il ne peut être interrompu!

Cela peut prendre beaucoup de temps sur une grande base, suivant les fonctions que vous avez sélectionné et leurs réglages en cours.

Etes vous sûr que vous voulez commencer les fonctions de maintenance que vous avez sélectionné?
}

translate F TwinCheckUndelete {pour permuter; "u" pour annuler l'effacement des deux}
translate F TwinCheckprevPair {Paire précédente}
translate F TwinChecknextPair {Paire suivante}
translate F TwinChecker {Scid: vérificateur de doublon}
translate F TwinCheckTournament {Parties dans le tournoi:}
translate F TwinCheckNoTwin {Pas de doublon  }
translate F TwinCheckNoTwinfound {No twin was detected for this game.\nTo show twins using this window, you must first use the "Delete twin games..." function. }
translate F TwinCheckTag {Partager tags...}
translate F TwinCheckFound1 {Scid a trouvé $result doublons}
translate F TwinCheckFound2 { et positionné le marquer de suppression}
translate F TwinCheckNoDelete {Il n'y a pas de parties dans cette base à effacer.}
translate F TwinCriteria1 { Les paramètres pour trouver des doublons risquent de\nfaire que des parties différentes avec des coups similaires soient marquées comme des doublons.}
translate F TwinCriteria2 {Il est recommandé de sélectionner "Non" pour "mêmes coups", vous devriez sélectionner "Oui" pour les couleurs, événement, site, ronde, année et mois.\nVoulez-vous continuer et effacer les doublons quand même ? }
translate F TwinCriteria3 {Il est recommandé de sélectionner "Oui" pour au moins deux des paramètres "même site", "même ronde" et "même année".\nVoulez-vous continuer et effacer les doublons quand même ?}
translate F TwinCriteriaConfirm {Scid: Confirmer les paramètres de doublons}
translate F TwinChangeTag "Changer les tags de partie suivants:\n\n"
translate F AllocRatingDescription "Cette commande va utiliser les fichiers de vérification de noms et de classement ELO pour les parties de cette base. Chaque fois qu'un joueur n'a pas de classement mais que son classement est listé dans le fichier de vérification de noms à la date de la partie, ce classement est pris en compte."
translate F RatingOverride "Remplacer le classement non nul existant"
translate F AddRatings "ajouter classement à:"
translate F AddedRatings {Scid a ajouté $r classements Elo dans $g parties.}
translate F NewSubmenu "Nouveau sous-menu"

# Comment editor:
translate F AnnotationSymbols {Symboles d'annotation:}
translate F Comment {Commentaire:}
translate F InsertMark {Insère une marque}
translate F InsertMarkHelp {
Insérer/enlever marque: Sélectionner la couleur, le type et la case.
Insérer/enlever flèche: Clic droit sur deux cases.
}

# Nag buttons in comment editor:
translate F GoodMove {Bon coup}
translate F PoorMove {Coup faible}
translate F ExcellentMove {Excellent coup}
translate F Blunder {Gaffe}
translate F InterestingMove {Coup intéressant}
translate F DubiousMove {coup douteux}
translate F WhiteDecisiveAdvantage {Les blancs ont un avantage décisif}
translate F BlackDecisiveAdvantage {Les noirs ont un avantage décisif}
translate F WhiteClearAdvantage {Les blancs ont l'avantage}
translate F BlackClearAdvantage {Les noirs ont l'avantage}
translate F WhiteSlightAdvantage {Les blancs ont un léger avantage}
translate F BlackSlightAdvantage {Les noirs ont un léger avantage}
translate F Equality {Egalité}
translate F Unclear {Peu clair}
translate F Diagram {Diagramme}

# Board search:
translate F BoardSearch {Rechercher Position}
translate F FilterOperation {Opération sur le filtre en cours:}
translate F FilterAnd {ET (Restreint le filtre)}
translate F FilterOr {OU (Ajouter au filtre)}
translate F FilterIgnore {IGNORER (Restaure le filtre initial)}
translate F SearchType {Type de recherche:}
translate F SearchBoardExact {Position exacte (mêmes pièces sur les mêmes cases)}
translate F SearchBoardPawns {Pions (même matériel, tous les pions sur les mêmes cases)}
translate F SearchBoardFiles {Colonnes (même matériel, tous les pions sur mêmes colonnes)}
translate F SearchBoardAny {Tous (même matériel, pions et pièces n'importe où)}
translate F SearchInRefDatabase { Dans la base de référence }
translate F LookInVars {Chercher dans les variantes}

# Material search:
translate F MaterialSearch {Rechercher Motifs}
translate F Material {Matériel}
translate F Patterns {Motifs}
translate F Zero {Zéro}
translate F Any {Tout}
translate F CurrentBoard {Position en cours}
translate F CommonEndings {Finales}
translate F CommonPatterns {Motifs}
translate F MaterialDiff {Différence en matériel}
translate F squares {cases}
translate F SameColor {Mêmes couleur}
translate F OppColor {Couleurs opposées}
translate F Either {Les deux}
translate F MoveNumberRange {Déplacer de X coups}
translate F MatchForAtLeast {Correspond à la dernière}
translate F HalfMoves {demi-coups}

# Common endings in material search:
translate F EndingPawns {Finales de pions}
translate F EndingRookVsPawns {Tour contre pion(s)}
translate F EndingRookPawnVsRook {Tour et 1 pion contre Tour}
translate F EndingRookPawnsVsRook {Tour et pion(s) contre Tour}
translate F EndingRooks {Finales Tour contre Tour}
translate F EndingRooksPassedA {Finales de Tour contre Tour avec un pion a passé}
translate F EndingRooksDouble {Finales 2 tours}
translate F EndingBishops {Finales Fou contre Fou}
translate F EndingBishopVsKnight {Finales Fou contre Cavalier}
translate F EndingKnights {Finales Cavalier contre Cavalier}
translate F EndingQueens {Finales Dame contre Dame}
translate F EndingQueenPawnVsQueen {Dame et 1 pion contre Dame}
translate F BishopPairVsKnightPair {Milieu de jeu 2 Fous contre 2 Cavaliers}

# Common patterns in material search:
translate F PatternWhiteIQP {White IQP} ;# ***
translate F PatternWhiteIQPBreakE6 {White IQP: d4-d5 break vs. e6} ;# ***
translate F PatternWhiteIQPBreakC6 {White IQP: d4-d5 break vs. c6} ;# ***
translate F PatternBlackIQP {Black IQP} ;# ***
translate F PatternWhiteBlackIQP {White IQP vs. Black IQP} ;# ***
translate F PatternCoupleC3D4 {White c3+d4 Isolated Pawn Couple} ;# ***
translate F PatternHangingC5D5 {Black Hanging Pawns on c5 and d5} ;# ***
translate F PatternMaroczy {Maroczy Center (with Pawns on c4 and e4)} ;# ***
translate F PatternRookSacC3 {Rook Sacrifice on c3} ;# ***
translate F PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)} ;# ***
translate F PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)} ;# ***
translate F PatternLightFian {Light-Square Fianchettos (Bishop-g2 vs. Bishop-b7)} ;# ***
translate F PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 vs. Bishop-g7)} ;# ***
translate F PatternFourFian {Four Fianchettos (Bishops on b2,g2,b7,g7)} ;# ***

# Game saving:
translate F Today {Aujourd'hui}
translate F ClassifyGame {Classer la partie}

# Setup position:
translate F EmptyBoard {Vider l'échiquier}
translate F InitialBoard {Ré-initialiser l'échiquier}
translate F SideToMove {Coté qui a le trait}
translate F MoveNumber {Coup numéro}
translate F Castling {Roque}
translate F EnPassantFile {Prise en passant}
translate F ClearFen {Effacer FEN}
translate F PasteFen {Coller FEN}
translate F SaveAndContinue {Enregistrer et continuer}
translate F DiscardChangesAndContinue {Ignorer changements\net continuer}
translate F GoBack {Revenir}

# Replace move dialog:
translate F ReplaceMove {Remplacer le coup}
translate F AddNewVar {Ajouter variante}
translate F NewMainLine {Ligne principale}
translate F ReplaceMoveMessage {Un coup existe déjà.

Vous pouvez le remplacer, ou bien détruire tous les coups après ce coup ou ajouter une nouvelle variante.

(Vous pouvez demander à ne plus voir ce message à l'avenir, en désélectionnant l'option "Demander avant de remplacer le coup" dans le menu des options)}

# Make database read-only dialog:
translate F ReadOnlyDialog {Si vous mettez cette base en lecture seule, aucun changement ne sera permis.
Aucune partie ne peut être sauvée ou remplacée, et aucun drapeau d'effacement ne peut être altéré.
Tout les tris ou les résultats de classification ECO seront temporaires.

Vous pouvez facilement rendre la base à nouveau accessible en écriture, en la fermant et en l'ouvrant à nouveau.

Voulez vous vraiment passer cette base en lecture seule?}

# Clear game dialog:
translate F ClearGameDialog {Cette partie a été modifiée.

Voulez vous vraiment continuer et ignorer les changements effectués?
}

# Exit dialog:
translate F ExitDialog {Voulez vous réellement quitter Scid?}
translate F ExitUnsaved {Les bases de données suivantes ont des parties modifiées non sauvegardées. Si vous quittez maintenant, ces modifications seront perdues.}

# Import window:
translate F PasteCurrentGame {Coller la partie courante}
translate F ImportHelp1 {Entrer ou coller une partie au format PGN dans le cadre ci-dessus.}
translate F ImportHelp2 {Toutes les erreurs durant l'import de la partie seront affichées ici.}
translate F OverwriteExistingMoves {Effacer les coups existants ?}

# ECO Browser:
translate F ECOAllSections {toutes les sections ECO}
translate F ECOSection {section ECO}
translate F ECOSummary {Résumé pour}
translate F ECOFrequency {Fréquence des sous-codes pour}

# Opening Report:
translate F OprepTitle {Rapport sur l'ouverture}
translate F OprepReport {Rapport}
translate F OprepGenerated {Généré par}
translate F OprepStatsHist {Statistiques et Historique}
translate F OprepStats {Statistiques}
translate F OprepStatAll {Toutes les parties du rapport}
translate F OprepStatBoth {Les deux joueurs classés}
translate F OprepStatSince {Depuis}
translate F OprepOldest {Les parties les plus anciennes}
translate F OprepNewest {Les parties les plus récentes}
translate F OprepPopular {Popularité courante}
translate F OprepFreqAll {Fréquence pour toutes les années: }
translate F OprepFreq1   {Depuis 1 an jusqu'à ce jour:      }
translate F OprepFreq5   {Depuis 5 ans jusqu'à ce jour:     }
translate F OprepFreq10  {Depuis 10 ans jusqu'à ce jour:    }
translate F OprepEvery {une fois toutes les %u parties}
translate F OprepUp {%u%s rencontré pour l'ensemble des années}
translate F OprepDown {%u%s non rencontré l'ensemble des années}
translate F OprepSame {sans changement par rapport à l'ensemble des années}
translate F OprepMostFrequent {Joueurs les plus fréquents}
translate F OprepMostFrequentOpponents {Adversaires les plus fréquents}
translate F OprepRatingsPerf {Classements et performance}
translate F OprepAvgPerf {Classements moyens et performance}
translate F OprepWRating {Classement des blancs}
translate F OprepBRating {Classement des noirs}
translate F OprepWPerf {Performance des blancs}
translate F OprepBPerf {Performance des noirs}
translate F OprepHighRating {Parties avec le classement moyen le plus élevé}
translate F OprepTrends {Tendances de résultat}
translate F OprepResults {Résultats longueurs et fréquences}
translate F OprepLength {Longueur de partie}
translate F OprepFrequency {Fréquence}
translate F OprepWWins {Gains blancs: }
translate F OprepBWins {Gains noirs:  }
translate F OprepDraws {Nulles:       }
translate F OprepWholeDB {base complète}
translate F OprepShortest {Gains les plus rapides}
translate F OprepMovesThemes {Coups et Thèmes}
translate F OprepMoveOrders {Ordres de coups atteignant la position du rapport}
translate F OprepMoveOrdersOne \
  {Il n'y a qu'un seul ordre de coups pour atteindre cette position:}
translate F OprepMoveOrdersAll \
  {Il y a %u ordres de coups pour atteindre cette position:}
translate F OprepMoveOrdersMany \
  {Il y a %u ordres de coups pour atteindre cette position. Les %u premiers sont:}
translate F OprepMovesFrom {Coups depuis la position du rapport}
translate F OprepMostFrequentEcoCodes {Codes ECO les plus fréquents}
translate F OprepThemes {Thèmes positionnels}
translate F OprepThemeDescription {Fréquence des thèmes dans les premiers %u coups de chaque partie}
translate F OprepThemeSameCastling {Roques du même côté}
translate F OprepThemeOppCastling {Roques du côté opposé}
translate F OprepThemeNoCastling {Aucun roque}
translate F OprepThemeKPawnStorm {Avalanche de pions à l'aile roi}
translate F OprepThemeQueenswap {Dames échangées}
translate F OprepThemeWIQP {Pion Dame blanc isolé}
translate F OprepThemeBIQP {Pion Dame noir isolé}
translate F OprepThemeWP567 {Pion blanc sur la 5/6/7e rangée}
translate F OprepThemeBP234 {Pion noir sur la 2/3/4e rangée}
translate F OprepThemeOpenCDE {Colonne c/d/e ouverte}
translate F OprepTheme1BishopPair {Paire de fous}
translate F OprepEndgames {Finales}
translate F OprepReportGames {Les parties du rapport}
translate F OprepAllGames {Toutes les parties}
translate F OprepEndClass {Classification du matériel des positions finales}
translate F OprepTheoryTable {Table de Théorie}
translate F OprepTableComment {Généré à partir des %u parties au classement le plus élevé.}
translate F OprepExtraMoves {Nombre de coups additionnels dans la table de théorie}
translate F OprepMaxGames {Nombre maximum de parties dans la table de théorie}
translate F OprepViewHTML {Voir en HTML}
translate F OprepViewLaTeX {Voir en LaTeX}

# Player Report:
translate F PReportTitle {Rapport du joueur}
translate F PReportColorWhite {avec les Blancs pièces}
translate F PReportColorBlack {avec les Noirs pièces}
translate F PReportMoves {après %s}
translate F PReportOpenings {Ouvertures}
translate F PReportClipbase {Vider le presse-papier et copier dedans toutes les parties qui correspondent}

# Piece Tracker window:
translate F TrackerSelectSingle {Le bouton gauche de la souris sélectionne cette pièce.}
translate F TrackerSelectPair {Le bouton gauche de la souris sélectionne cette pièce; le bouton droit sélectionne aussi son pendant.}
translate F TrackerSelectPawn {Le bouton gauche de la souris sélectionne ce pion ; le bouton droit sélectionne les 8 pions.}
translate F TrackerStat {Statistiques}
translate F TrackerGames {% parties avec déplacement sur la case}
translate F TrackerTime {% fois sur chaque case}
translate F TrackerMoves {Coups}
translate F TrackerMovesStart {Entrer le numéro du coups à partir duquel la recherche doit commencer.}
translate F TrackerMovesStop {Entrer le numéro du coups auquel la recherche doit s'arrêter.}

# Game selection dialogs:
translate F SelectAllGames {Toutes les parties de la base}
translate F SelectFilterGames {Seulement les parties du filtre}
translate F SelectTournamentGames {Seulement les parties du tournoi courant}
translate F SelectOlderGames {Seulement les parties plus anciennes}

# Delete Twins window:
translate F TwinsNote {Pour être considérées comme doublons, deux parties doivent au moins avoir les deux mêmes joueurs, et avoir les critères que vous pouvez fixer ci-dessous satisfaits. Quand une paire de doublons est trouvée, la partie la plus courte est effacée. Conseil: il est préférable de vérifier l'orthographe dans la base avant d'effacer les doublons, car cela améliore la détection des doublons. }
translate F TwinsCriteria {Critère: Les doublons doivent avoir...}
translate F TwinsWhich {Parties à examiner}
translate F TwinsColors {Même couleurs de joueurs}
translate F TwinsEvent {Même évènement}
translate F TwinsSite {Même lieu}
translate F TwinsRound {Même ronde}
translate F TwinsYear {Même année}
translate F TwinsMonth {Même mois}
translate F TwinsDay {Même jour}
translate F TwinsResult {Même résultat}
translate F TwinsECO {Même code ECO}
translate F TwinsMoves {Mêmes coups}
translate F TwinsPlayers {Comparaison des noms des joueurs}
translate F TwinsPlayersExact {Correspondance exacte}
translate F TwinsPlayersPrefix {Les 4 premières lettres seules}
translate F TwinsWhen {En effacant les doublons}
translate F TwinsSkipShort {Ignorer toutes les parties de moins de cinq coups}
translate F TwinsUndelete {Récupérer toutes les parties d'abord}
translate F TwinsSetFilter {Appliquer le filtre à tous les doublons éliminés}
translate F TwinsComments {Toujours garder les parties qui comportent des commentaires}
translate F TwinsVars {Toujours garder les parties qui comportent des variantes}
translate F TwinsDeleteWhich {Partie à effacer}
translate F TwinsDeleteShorter {La partie la plus courte}
translate F TwinsDeleteOlder {La partie avec le plus petit numéro}
translate F TwinsDeleteNewer {La partie avec le plus grand numéro}
translate F TwinsDelete {Effacer les parties}

# Name editor window:
translate F NameEditType {Taper le nom à éditer}
translate F NameEditSelect {Parties à éditer}
translate F NameEditReplace {Remplacer}
translate F NameEditWith {avec}
translate F NameEditMatches {Correspondances: Presser Alt+1 à Alt+9 pour sélectionner}
# ====== TODO To be translated ======
translate F CheckGames {Check games}
# ====== TODO To be translated ======
translate F CheckGamesWhich {Check games}
# ====== TODO To be translated ======
translate F CheckAll {All games}
# ====== TODO To be translated ======
translate F CheckSelectFilterGames {Only games in filter}

# Classify window:
translate F Classify {Classer}
translate F ClassifyWhich {Choix des parties à classer suivant ECO}
translate F ClassifyAll {Toutes les parties (écrase les anciens codes ECO)}
translate F ClassifyYear {Toutes les parties jouées la dernière année}
translate F ClassifyMonth {Toutes les parties jouées le dernier mois}
translate F ClassifyNew {Seulement les parties qui ne possèdent pas encore de code ECO}
translate F ClassifyCodes {Codes ECO à utiliser}
translate F ClassifyBasic {Codes de base seulement ("B12", ...)}
translate F ClassifyExtended {Extensions de Scid ("B12j", ...)}

# Compaction:
translate F NameFile {Fichier de noms}
translate F GameFile {Fichier de parties}
translate F Names {Noms}
translate F Unused {Non utilisé}
translate F SizeKb {Taille (kb)}
translate F CurrentState {État courant}
translate F AfterCompaction {Après compactage}
translate F CompactNames {Compacter le fichier de noms}
translate F CompactGames {Compacter le fichier de parties}
translate F NoUnusedNames "Il n'y a pas de noms inutilisés, le fichier de noms est donc déjà compacté."
translate F NoUnusedGames "Le fichier des parties est déjà compacté."
translate F GameFileCompacted {Le fichier de parties de la base a été compacté.}

# Sorting:
translate F SortCriteria {Critère}
translate F AddCriteria {Ajouter un critère}
translate F CommonSorts {Tris courants}
translate F Sort {Tri}

# Exporting:
translate F AddToExistingFile {Ajouter les parties à un fichier existant?}
translate F ExportComments {Exporter les commentaires?}
translate F ExportVariations {Exporter les variantes?}
translate F IndentComments {Indenter les commentaires?}
translate F IndentVariations {Indenter les variantes?}
translate F ExportColumnStyle {Style en colonne (un coup par ligne)?}
translate F ExportSymbolStyle {Style d'annotation symbolique:}
translate F ExportStripMarks {Enlever les codes de marquages de flèches et de coloration de cases des commentaires?}

# Goto game/move dialogs:
translate F LoadGameNumber {Entrer le numéro de la partie à charger:}
translate F GotoMoveNumber {Aller au coup numéro:}

# Copy games dialog:
translate F CopyGames {Copier les parties}
translate F CopyConfirm {
 Voulez vous vraiment copier
 les [::utils::thousands $nGamesToCopy] parties filtrées
 depuis la base "$fromName"
 vers la base "$targetName"?
}
translate F CopyErr {Ne peut copier les parties}
translate F CopyErrSource {la base source}
translate F CopyErrTarget {la base destination}
translate F CopyErrNoGames {n'a pas de parties dans son filtre}
translate F CopyErrReadOnly {est en lecture seule}
translate F CopyErrNotOpen {n'est pas ouverte}

# Colors:
translate F LightSquares {Cases blanches}
translate F DarkSquares {Cases noires}
translate F SelectedSquares {Cases sélectionnées}
translate F SuggestedSquares {Cases des coups suggérés}
translate F WhitePieces {Pièces blanches}
translate F BlackPieces {Pièces noires}
translate F WhiteBorder {Bordure des pièces blanches}
translate F BlackBorder {Bordure des pièces noires}

# Novelty window:
translate F FindNovelty {Trouver la nouveauté}
translate F Novelty {Nouveauté}
translate F NoveltyInterrupt {Recherche de nouveauté interrompue}
translate F NoveltyNone {Aucune nouveauté n'a été trouvée pour cette partie}
translate F NoveltyHelp {Scid va trouver le premier coup de la partie en cours qui atteint une position qui ne figure ni dans la base sélectionnée ni dans le répertoire d'ouvertures ECO.}

# Sounds configuration:
translate F SoundsFolder {Répertoire des fichiers sonores}
translate F SoundsFolderHelp {Le répertoire devrait contenir les fichiers King.wav, a.wav, 1.wav, etc}
translate F SoundsAnnounceOptions {Options d'annonce des coups}
translate F SoundsAnnounceNew {Annoncer les coups joués}
translate F SoundsAnnounceForward {Annoncer les coups quand avance d'un coup}
translate F SoundsAnnounceBack {Annoncer quand retour arrière d'un coup}

# Upgrading databases:
translate F Upgrading {Mise à jour}
translate F ConfirmOpenNew {
Ceci est une base de données à l'ancien format (Scid 3) qui ne peut être ouverte dans Scid 4, mais une version au nouveau format (Scid 4) a déjà été crée.

Voulez vous ouvrir le nouveau format de la base de données?
}
translate F ConfirmUpgrade {
Ceci est une base de données à l'ancien format (Scid 3). Une version de la base de données au nouveau format doit être créée avant de pouvoir être utilisée dans Scid 4.

Mettre à jour va créer une nouvelle version de la base de données; les fichiers originaux seront effacés.

Cela peut prendre un peu de temps, mais il n'est nécessaire de le faire qu'une fois. Vous pouvez abandonner si cela dure trop longtemps.

Voulez vous mettre à jour cette base de données maintenant?
}

# Recent files options:
translate F RecentFilesMenu {Nombre de fichiers récents dans le menu Fichier}
translate F RecentFilesExtra {Nombre de fichiers récents dans le sous-menu complémentaire}

# My Player Names options:
translate F MyPlayerNamesDescription {
Entrer ci-dessous une liste des noms des joueurs préférés, un nom par ligne. Les caractères spéciaux (i.e. "?" pour un seul caractère, "*" pour n'importe quelle suite de caractères) sont autorisés.

Chaque fois qu'une partie avec un joueur de la liste est chargée, l'échiquier de la fenêtre principale sera tourné si nécessaire de façon à montrer la partie selon le point de vue du joueur.
}
#Coach
translate F showblunderexists {Montrer si erreur}
translate F showblundervalue {Montrer la valeur de l'erreur}
translate F showscore {Montrer score}
translate F coachgame {Entrainement}
translate F configurecoachgame {Configurer une partie avec entraineur}
translate F configuregame {Configuration de partie}
translate F Phalanxengine {moteur Phalanx}
translate F Coachengine {entraineur}
translate F difficulty {difficulté}
translate F hard {difficile}
translate F easy {facile}
translate F Playwith {Jouer avec}
translate F white {blanc}
translate F black {noir}
translate F both {les deux}
translate F Play {Jouer}
translate F Noblunder {Pas d'erreur}
translate F blunder {erreur}
translate F Noinfo {-- Pas d'info --}
translate F PhalanxOrTogaMissing {Phalanx ou Toga non trouvé}
translate F moveblunderthreshold {le coup est une erreur si les pertes sont supérieures à }
translate F limitanalysis {limiter le temps d'analyse}
translate F seconds {secondes}
translate F Abort {Arrêter}
translate F Resume {Reprendre}
translate F OutOfOpening {Hors de l'ouverture}
translate F NotFollowedLine {Vous n'avez pas suivi la ligne}
translate F DoYouWantContinue {Voulez-vous continuer ?}
translate F CoachIsWatching {L'entraineur regarde}
translate F Ponder {Réflexion permanente}
translate F LimitELO {Limiter force ELO}
translate F DubiousMovePlayedTakeBack {Coup douteux joué, voulez-vous reprendre le coup ?}
translate F WeakMovePlayedTakeBack {Coup faible joué, voulez-vous reprendre le coup ?}
translate F BadMovePlayedTakeBack {Mauvais coup joué, voulez-vous reprendre le coup ?}
translate F Iresign {J'abandonne}
translate F yourmoveisnotgood {Votre coup n'est pas bon}
translate F EndOfVar {Fin de variante}
translate F Openingtrainer {Entrainement aux ouvertures}
translate F DisplayCM {Afficher les coups candidats}
translate F DisplayCMValue {Afficher la valeur des coups candidats}
translate F DisplayOpeningStats {Montrer statistiques}
translate F ShowReport {Montrer rapport}
translate F NumberOfGoodMovesPlayed {bons coups joués}
translate F NumberOfDubiousMovesPlayed {coups douteux joués}
translate F NumberOfMovesPlayedNotInRepertoire {coups joués absents du répertoire}
translate F NumberOfTimesPositionEncountered {nombre de fois position rencontrée}
translate F PlayerBestMove  {N'autoriser que les meilleurs coups}
translate F OpponentBestMove {Ne jouer que les meilleurs coups}
translate F OnlyFlaggedLines {Seulement les lignes marquées}
translate F resetStats {Remettre à zéro les scores}
translate F Repertoiretrainingconfiguration {Configuration entrainement répertoire}
translate F Loadingrepertoire {Chargement du répertoire}
translate F Movesloaded {Coups lus}
translate F Repertoirenotfound {Répertoire introuvable}
translate F Openfirstrepertoirewithtype {Ouvrez d'abord une base avec le bon type/icône sur le côté droit}
translate F Movenotinrepertoire {Coup absent du répertoire}
translate F PositionsInRepertoire {Positions dans le répertoire}
translate F PositionsNotPlayed {Positions non jouées}
translate F PositionsPlayed {Positions jouées}
translate F Success {Succès}
translate F DubiousMoves {Coups douteux}
translate F OutOfRepertoire {Hors du répertoire}
translate F ConfigureTactics {Configurer exercices tactiques}
translate F ResetScores {Remise à zéro des scores}
translate F LoadingBase {Chargement de la base}
translate F Tactics {Tactique}
translate F ShowSolution {Montrer la solution}
translate F NextExercise {Exercice suivant}
translate F PrevExercise {Exercice précédent}
translate F StopTraining {Arrêter l'entrainement}
translate F Next {Suivant}
translate F ResettingScore {Remise à zéro des scores}
translate F LoadingGame {Chargement partie}
translate F MateFound {Mat trouvé}
translate F BestSolutionNotFound {Meilleur coup non trouvé !}
translate F MateNotFound {Mat non trouvé}
translate F ShorterMateExists {Un mat plus rapide existe}
translate F ScorePlayed {score coup joué}
translate F Expected {attendu}
translate F ChooseTrainingBase {Choisir la base d'exercices}
translate F Thinking {Calcul en cours}
translate F AnalyzeDone {Analyse terminée}
translate F WinWonGame {Terminer partie gagnée}
translate F Lines {Lignes}
translate F ConfigureUCIengine {Configurer moteur UCI}
translate F SpecificOpening {Ouverture spécifique}
translate F StartNewGame {Nouvelle partie}
translate F FixedLevel {Niveau fixe}
translate F Opening {Ouverture}
translate F RandomLevel {Niveau aléatoire}
translate F StartFromCurrentPosition {Jouer depuis la position actuelle}
translate F FixedDepth {Profondeur fixe}
translate F Nodes {Noeuds} 
translate F Depth {Profondeur}
translate F Time {Temps} 
translate F SecondsPerMove {Secondes par coup}
translate F Engine {Moteur}
translate F TimeMode {Mode de réflexion}
translate F TimeBonus {Temps + bonus}
translate F TimeMin {min}
translate F TimeSec {sec}
translate F AllExercisesDone {Tous les exercices sont faits}
translate F MoveOutOfBook {Coup hors bibliothèque d'ouverture}
translate F LastBookMove {Dernier coup de la bibliothèque d'ouverture}
translate F AnnotateSeveralGames {Annotater plusieurs parties\ndepuis l'actuelle jusqu'à :}
translate F FindOpeningErrors {Chercher les erreurs d'ouverture}
translate F MarkTacticalExercises {Marquer exercices tactiques}
translate F UseBook {Utiliser bibliothèque}
translate F MultiPV {Nombre de variantes}
translate F Hash {Mémoire}
translate F OwnBook {Utiliser bibliothèque propre}
translate F BookFile {Bibliothèque d'ouverture}
translate F AnnotateVariations {Annotater les variantes}
translate F ShortAnnotations {Annotations courtes}
translate F addAnnotatorTag {Ajouter Annotateur}
translate F AddScoreToShortAnnotations {Ajouter score aux annotations courtes}
translate F Export {Exporter}
translate F BookPartiallyLoaded {Bibliothèque chargée en partie}
translate F Calvar {Calcul de variantes}
translate F ConfigureCalvar {Configuration}
# Opening names used in tacgame.tcl
translate F Reti {Reti}
translate F English {Anglaise}
translate F d4Nf6Miscellaneous {1.d4 Cf6 divers}
translate F Trompowsky {Trompowsky}
translate F Budapest {Budapest}
translate F OldIndian {Vieille Indienne}
translate F BenkoGambit {Gambit Benko}
translate F ModernBenoni {Benoni Moderne}
translate F DutchDefence {Défense hollandaise}
translate F Scandinavian {Scandinave}
translate F AlekhineDefence {Défense Alekhine}
translate F Pirc {Pirc}
translate F CaroKann {Caro-Kann}
translate F CaroKannAdvance {Caro-Kann Avance}
translate F Sicilian {Sicilienne}
translate F SicilianAlapin {Sicilienne Alapin}
translate F SicilianClosed {Sicilienne fermée}
translate F SicilianRauzer {Sicilienne Rauzer}
translate F SicilianDragon {Sicilienne Dragon}
translate F SicilianScheveningen {Sicilienne Scheveningen}
translate F SicilianNajdorf {Sicilienne Najdorf}
translate F OpenGame {Partie ouverte}
translate F Vienna {Viennoise}
translate F KingsGambit {Gambit Roi}
translate F RussianGame {Petroff}
translate F ItalianTwoKnights {Italienne/Deux cavaliers}
translate F Spanish {Espagnole}
translate F SpanishExchange {Espagnole échange}
translate F SpanishOpen {Espagnole ouverte}
translate F SpanishClosed {Espagnole fermée}
translate F FrenchDefence {Défense française}
translate F FrenchAdvance {Défense française Avance}
translate F FrenchTarrasch {Défense française Tarrasch}
translate F FrenchWinawer {Défense française Winawer}
translate F FrenchExchange {Défense française Echange}
translate F QueensPawn {Pion Dame}
translate F Slav {Slave}
translate F QGA {GD Accepté}
translate F QGD {GD Décliné}
translate F QGDExchange {GD Echange}
translate F SemiSlav {Semi-Slave}
translate F QGDwithBg5 {GD décliné avec Fg5}
translate F QGDOrthodox {GD décliné Orthodoxe}
translate F Grunfeld {Grünfeld}
translate F GrunfeldExchange {Grünfeld Echange}
translate F GrunfeldRussian {Grünfeld Russe}
translate F Catalan {Catalane}
translate F CatalanOpen {Catalane Ouverte}
translate F CatalanClosed {Catalane Fermée}
translate F QueensIndian {Ouest indienne}
translate F NimzoIndian {Nimzo-Indienne}
translate F NimzoIndianClassical {Nimzo-Indienne Classique}
translate F NimzoIndianRubinstein {Nimzo-Indienne Rubinstein}
translate F KingsIndian {Est-indienne}
translate F KingsIndianSamisch {Est-indienne Sämisch}
translate F KingsIndianMainLine {Est-indienne ligne principale}
translate F ConfigureFics {Configurer FICS}
translate F FICSGuest {Login comme invité}
translate F FICSServerPort {Port du serveur}
translate F FICSServerAddress {Adresse IP}
translate F FICSRefresh {Rafraîchir}
translate F FICSTimesealPort {Port Timeseal}
translate F FICSSilence {Silence}
translate F FICSOffers {Offres}
translate F FICSConsole {Console}
translate F FICSGames {Parties}
translate F FICSUnobserve {Arrêter de suivre la partie}
translate F FICSProfile {Afficher mon historique et mes données}
translate F FICSRelayedGames {Parties retransmises}
translate F FICSFindOpponent {Trouver adversaire}
translate F FICSTakeback {Reprendre un coup}
translate F FICSTakeback2 {Rependre deux coups}
translate F FICSInitTime {Temps initial (min)}
translate F FICSIncrement {Incrément (sec)}
translate F FICSRatedGame {Partie classée}
translate F FICSAutoColour {automatique}
translate F FICSManualConfirm {accepter manuellement}
translate F FICSFilterFormula {Filtrer avec formule}
translate F FICSIssueSeek {Envoyer seek}
translate F FICSChallenge {Challenge}
translate F FICSAccept {accepter}
translate F FICSDecline {refuser}
translate F FICSColour {Couleur}
translate F FICSSend {envoyer}
translate F FICSConnect {Connecter}
translate F FICSdefaultuservars {Variables par défaut}
translate F FICSObserveconfirm {Voulez-vous suivre la partie}
# ====== TODO To be translated ======
translate F FICSpremove {Enable premove}
translate F GameReview {Revue de partie}
translate F GameReviewTimeExtended {Temps étendu}
translate F GameReviewMargin {Marge d'erreur}
translate F GameReviewAutoContinue {Continuer quand le coup est correct}
translate F GameReviewReCalculate {Utiliser temps étendu}
translate F GameReviewAnalyzingMovePlayedDuringTheGame {Analyse du coup joué pendant la partie}
translate F GameReviewAnalyzingThePosition {Analyse de la position}
translate F GameReviewEnterYourMove {Jouez votre coup}
translate F GameReviewCheckingYourMove {Vérification de votre coup}
translate F GameReviewYourMoveWasAnalyzed {Votre coup a été analysé}
translate F GameReviewYouPlayedSameMove {Vous avez joué le même coup que dans la partie}
translate F GameReviewScoreOfYourMove {Score de votre coup}
translate F GameReviewGameMoveScore {Score du coup de la partie}
translate F GameReviewEngineScore {Score du moteur}
translate F GameReviewYouPlayedLikeTheEngine {Vous avez joué un coup aussi bon que le moteur}
translate F GameReviewNotEngineMoveButGoodMove {Pas le coup du moteur, mais un coup jouable}
translate F GameReviewMoveNotGood {Ce coup n'est pas bon, le score est}
translate F GameReviewMovesPlayedLike {Coups joués comme}
translate F GameReviewMovesPlayedEngine {coups joués comme le moteur}
translate F CCDlgConfigureWindowTitle {Configurer échecs par correspondance}
translate F CCDlgCGeneraloptions {Options générales}
translate F CCDlgDefaultDB {Base par défaut:}
translate F CCDlgInbox {Réception (chemin):}
translate F CCDlgOutbox {Envoi (chemin):}
translate F CCDlgXfcc {Configuration Xfcc:}
translate F CCDlgExternalProtocol {Protocole externe (p.e. Xfcc)}
translate F CCDlgFetchTool {Outil de réception:}
translate F CCDlgSendTool {Outil d'envoi:}
translate F CCDlgEmailCommunication {Communication eMail}
translate F CCDlgMailPrg {Programme de mail:}
translate F CCDlgBCCAddr {Addresse de copie:}
translate F CCDlgMailerMode {Mode:}
translate F CCDlgThunderbirdEg {p.e. Thunderbird, Mozilla Mail, Icedove...}
translate F CCDlgMailUrlEg {p.e. Evolution}
translate F CCDlgClawsEg {p.e Sylpheed Claws}
translate F CCDlgmailxEg {p.e. mailx, mutt, nail...}
translate F CCDlgAttachementPar {Attachement:}
translate F CCDlgInternalXfcc {Utiliser Xfcc interne}
translate F CCDlgConfirmXfcc {Confirmer coups}
translate F CCDlgSubjectPar {Objet:}
translate F CCDlgDeleteBoxes {Vider boîtes}
translate F CCDlgDeleteBoxesText {Voulez-vous réellement vider les boîtes entrantes et sortantes pour les échecs par correspondance ? Cela nécessite une nouvelle synchronisation pour afficher le dernier état de vos parties}
translate F CCDlgConfirmMove {Confirmer coup}
translate F CCDlgConfirmMoveText {Si vous confirmez, le coup ci-dessous et le commentaire sont envoyés au serveur:}
translate F CCDlgDBGameToLong {Ligne principale incohérente}
translate F CCDlgDBGameToLongError {La ligne principale dans votre base de données est plus longue que la partie dans votre boîte de réception. Si la boîte de réception contient les parties en cours, c'est-à-dire juste après une synchronisation, certains coups ont été ajoutés à tort à la ligne principale dans la base de données.\nDans ce cas veuillez raccourcir la ligne principale à au plus coup\n}
translate F CCDlgStartEmail {Commencer nouvelle partie par eMail}
translate F CCDlgYourName {Votre nom:}
translate F CCDlgYourMail {Votre adresse mail:}
translate F CCDlgOpponentName {Nom adversaire:}
translate F CCDlgOpponentMail {Adresse eMail adversaire:}
translate F CCDlgGameID {Identifiant Partie (unique):}
translate F CCDlgTitNoOutbox {Scid: Boîte d'envoi}
translate F CCDlgTitNoInbox {Scid: Boîte de réception}
translate F CCDlgTitNoGames {Scid: Pas de parties par correspondence}
translate F CCErrInboxDir {Répertoire de la boîte de réception:}
translate F CCErrOutboxDir {Répertoire de la boîte d'envoi:}
translate F CCErrDirNotUsable {n'existe pas ou inaccessible!\nVeuillez vérifier les paramètres.}
translate F CCErrNoGames {ne contient pas de parties!\nVeuillez d'abord les récupérer.}
translate F CCDlgTitNoCCDB {Scid: pas de base par correspondance}
translate F CCErrNoCCDB {Aucune base du type 'Correspondance' n'est ouverte. Ouvrez-en une avant d'utiliser les fonctions par correspondance.}
translate F CCFetchBtn {Récupérer les parties sur le serveur et les analyser dans la boîte de réception}
translate F CCPrevBtn {Aller à la partie précédente}
translate F CCNextBtn {Aller à la partie suivante}
translate F CCSendBtn {Envoyer coup}
translate F CCEmptyBtn {Vider les boîtes d'envoi et de réception}
translate F CCHelpBtn {Aide sur les icônes et indicateurs.\nPour plus d'aide appuyer sur F1!}
translate F CCDlgServerName {Nom serveur:}
translate F CCDlgLoginName  {Login:}
translate F CCDlgPassword   {Mot de passe:}
# ====== TODO To be translated ======
translate F CCDlgShowPassword {Show password}
translate F CCDlgURL        {Xfcc-URL:}
translate F CCDlgRatingType {Type classement:}
translate F CCDlgDuplicateGame {Identifiant de partie non-unique}
translate F CCDlgDuplicateGameError {Cette partie existe à plusieurs exemplaires dans la base de données. Veuillez effacer tous les doublons et compacter votre fichier de parties (Fichier/Maintenance/Compacter base).}
translate F CCDlgSortOption {Tri:}
translate F CCDlgListOnlyOwnMove {Parties où c'est mon tour}
translate F CCOrderClassicTxt {Site, Evénement, Ronde, Résultat, Blancs, Noirs}
translate F CCOrderMyTimeTxt {Ma pendule}
translate F CCOrderTimePerMoveTxt {Temps par coup jusqu'au prochain contrôlede temps}
translate F CCOrderStartDate {Date de départ}
translate F CCOrderOppTimeTxt {Pendule adversaire}
# ====== TODO To be translated ======
translate F CCDlgConfigRelay {Configure ICCF observations}
# ====== TODO To be translated ======
translate F CCDlgConfigRelayHelp {Go to the games page on http://www.iccf-webchess.com and display the game to be observed.  If you see the chessboard copy the URL from your browser to the list below. One URL per line only!\nExample: http://www.iccf-webchess.com/MakeAMove.aspx?id=266452}
translate F ExtHWConfigConnection {Configure external hardware}
translate F ExtHWPort {Port}
translate F ExtHWEngineCmd {Commande moteur}
translate F ExtHWEngineParam {Paramètre moteur}
translate F ExtHWShowButton {Montrer bouton}
translate F ExtHWHardware {Matériel}
translate F ExtHWNovag {Novag Citrine}
translate F ExtHWInputEngine {Moteur en entrée}
translate F ExtHWNoBoard {Pas d'échiquier}
translate F NovagReferee {Arbitre}
translate F IEConsole {Console du moteur en entrée}
translate F IESending {Coups envoyés pour}
translate F IESynchronise {Synchronizer}
translate F IERotate  {Tourner}
translate F IEUnableToStart {Impossible de démarrer le moteur en entrée:}
translate F DoneWithPosition {Position terminée}
translate F Board {Echiquier}
translate F showGameInfo {Montrer le panneau d'info}
translate F autoResizeBoard {Redimensionnement automatique}
translate F DockTop {Déplacer en haut}
translate F DockBottom {Déplacer en bas}
translate F DockLeft {Déplacer à gauche}
translate F DockRight {Déplacer à droite}
translate F Undock {Détacher}
translate F ChangeIcon {Changer icone...}
# ====== TODO To be translated ======
translate F NewGameListWindow {New Game List Window}
# ====== TODO To be translated ======
translate F LoadatStartup {Load at startup}
translate F ShowHideDB {Afficher/Masquer les bases de données}
translate F ChangeFilter {Remplacer le filtre}
translate F ChangeLayout {Charger/Enregistrer/Modifier les critères de tri et la disposition des colonnes.}
translate F ShowHideStatistic {Afficher/Masquer les statistiques}
translate F BoardFilter {Afficher uniquement les jeux qui correspondent à la position actuelle du plateau de jeu.}
translate F CopyGameTo {Copier le jeu dans}
translate F FindBar {Trouver un bar}
translate F FindCurrentGame {Trouver le jeu actuel}
translate F DeleteGame {Supprimer le jeu}
translate F UndeleteGame {Reconstitue le jeu}
translate F ResetSort {Réinitialiser le tri}
translate F ConvertNullMove {Convertir les mouvements nuls en commentaires}
# ====== TODO To be translated ======
translate F SetupBoard {Setup Board}
translate F Rotate {Rotation}
translate F SwitchColors {Changer de couleur}
# ====== TODO To be translated ======
translate F FlipBoard {Flip Board}
translate F ImportPGN {Importer un jeu PGN}
translate F ImportingFiles {Importing PGN files in}
translate F ImportingFrom {Importation de}
translate F ImportingIn {Importer des jeux dans}
translate F UseLastTag {Utilisez les tags de last\ngame's tags}
translate F Random {Aléatoire}
# ====== TODO To be translated ======
translate F BackToMainline {Go back to mainline}
# ====== TODO To be translated ======
translate F LeaveVariant {Leave variant}
# ====== TODO To be translated ======
translate F Autoplay {Autoplay}
# ====== TODO To be translated ======
translate F ShowHideCoords {Show/Hide Coord.}
# ====== TODO To be translated ======
translate F ShowHideMaterial {Show/Hide Material}
# ====== TODO To be translated ======
translate F FullScreen {Full Screen}
# ====== TODO To be translated ======
translate F FilterStatistic {Filter Statistics}
# ====== TODO To be translated ======
translate F MakeCorrections {Make Corrections}
# ====== TODO To be translated ======
translate F Surnames {Surnames}
# ====== TODO To be translated ======
translate F Ambiguous {Ambiguous}

##########
#
# ECO Opening name translations:

# translateECO F {
  # Accelerated {, Accéléré}
  # {: Accelerated} Accéléré
  # Accepted {, accepté}
  # {: Accepted} Accepté
  # Advance Avance
  # {as Black} {avec les Noirs}
  # Attack Attaque
  # Bishop Fou
  # Bishop's Fou
  # Classical Classique
  # Closed Fermé
  # {Closed System} {Système fermé}
  # Counterattack Contre-Attaque
  # Countergambit Contre-Gambit
  # Declined {, Décliné}
  # Defence Défense
  # deferred différé
  # Deferred {, Différé}
  # Early Tôt
  # Exchange Echange
  # Game Partie
  # Improved amélioré
  # King's Roi
  # Knight Cavalier
  # Line Ligne
  # {Main Line} Ligne principale
  # Open Ouvert
  # Opening Ouverture
  # Queen's Dame
  # Queenswap Permutation de dame
  # Symmetrical Symétrique
  # Variation Variante
  # Wing Aile
  # with avec
  # without sans
  # 
  # Alekhine Alekhine
  # Averbakh Averbakh
  # Botvinnik Botvinnik
  # Chigorin Tchigorine
  # Polugaevsky Polugaevsky
  # Rauzer Rauzer
  # Sveshnikov Sveshnikov
  # 
  # Austrian Autrichien
  # Berlin Berlinois
  # Bremen Breme
  # Catalan Catalane
  # Czech Tchèque
  # Dutch Hollandaise
  # English Anglaise
  # French Française
  # Hungarian Hongroise
  # Indian Indienne
  # Italian Italienne
  # Latvian Letton
  # Meran Meran
  # Moscow Moscou
  # Polish Polonais
  # Prague Prague
  # Russian Russe
  # Scandinavian Scandinave
  # Scheveningen Scheveningen
  # Scotch Ecossaise
  # Sicilian Sicilienne
  # Slav Slave
  # Spanish Espagnole
  # Swedish Suédois
  # Swiss Suisse
  # Vienna Viennois
  # Yugoslav Yougoslave
  # 
  # {Accelerated Fianchetto} {Fianchetto Accéléré}
  # {Accelerated Pterodactyl} {Pterodactyle Accéléré}
  # {Alekhine Defence} Défense-Alekhine
  # {Alekhine Variation} Variante-Alekhine
  # {Alekhine: Sämisch Attack} {Alekhine: Système viennois (Attaque Sämisch)}
  # {Anderssen Opening} Ouverture-Anderssen
  # {Anti-King's Indian} Anti-Est-Indienne
  # {Austrian Attack} {Attaque Autrichienne}
  # {Benko Gambit} {Gambit Benko}
  # {Benko Opening} {Ouverture Benkö}
  # {Berlin Defence} {Défense Berlinoise}
  # Chameleon Cameleon
  # Chelyabinsk Chelyabinsk
  # {Classical Defence} {Défense Classique}
  # {Spanish: Classical Defence} {Espagnole: Défense Classique}
  # {Classical Exchange} {Echange Classique}
  # {Classical Variation} {Variante Classique}
  # {Closed Berlin} {Berlinoise Fermée}
  # {Open Berlin} {Berlinoise Ouverte}
  # {Bird's,} {Bird,}
  # {Bird's Defence} {Défense Bird}
  # {Bird's Deferred} {Bird Différée}
  # {Bishop's Opening} {Ouverture du Fou}
  # {Botvinnik System} {Système Botvinnik}
  # {Central Variation} {Variante du centre}
  # {Centre Attack} {Attaque du centre}
  # {Centre Game} {Ouverture du centre}
  # {Danish Gambit} {Gambit Danois}
  # Dragon Dragon
  # {Dutch Variation} {Variante Hollandaise}
  # {Early Exchange} {Echange rapide}
  # {Early Queenswap} {Echange de Dames rapide}
  # {English Attack} {Attaque Anglaise}
  # {English: King's} {Anglaise: Roi}
  # {English Variation} {Variante Anglaise}
  # {Englund Gambit} {Gambit Englund}
  # {Exchange Variation} {Variante d'échange}
  # {Fianchetto Variation} {Variante du Fianchetto}
  # {Flohr Variation} {Variante Flohr}
  # {Four Knights} {Quatre Cavaliers}
  # {Four Knights Game} {Partie des Quatre Cavaliers}
  # {Four Pawns} {Quatre Pions}
  # {Four Pawns Attack} {Attaque des Quatre Pions}
  # {French Variation} {Variante Française}
  # {From Gambit} {Gambit From}
  # {Goring Gambit} {Gambit Göring}
  # {Grob Gambit} {Gambit Grob}
  # {Hungarian Defence} {Défense Hongroise}
  # {Indian Variation} {Variante Indienne}
  # {Italian Game} {Partie Italienne}
  # KGD {Gambit Roi Décliné}
  # {Classical KGD} {Gambit Roi Décliné Classique}
  # {Keres Variation} {Variante Keres}
  # KGA {Gambit Roi Accepté}
  # {KGA: Bishop's Gambit} {Gambit Roi Accepté: Gambit du Fou}
  # {KGA: King's Knight Gambit} {Gambit Roi Accepté: Gambit du Cavalier}
  # {King's Gambit} {Gambit Roi}
  # {King's Gambit Accepted} {Gambit Roi Accepté}
  # {King's Gambit Accepted (KGA)} {Gambit Roi Accepté}
  # {King's Indian} Est-Indienne
  # KIA {Attaque Est-Indienne}
  # {King's Knight Gambit} {Gambit du Cavalier Roi}
  # {King's Pawn} {Pion Roi}
  # {Lasker Variation} {Variante Lasker}
  # {Latvian Gambit} {Gambit Letton}
  # {Maroczy Bind} {Maroczy}
  # {Marshall Variation} {Variante Marshall}
  # {Modern Attack} {Attaque Moderne}
  # {Modern Steinitz} {Steinitz Moderne}
  # {Modern Variation} {Variante Moderne}
  # {Moscow Variation} {Variante de Moscou}
  # Nimzo-Indian Nimzo-Indienne
  # {Old Benoni} {Vieille Benoni}
  # {Old Indian} {Vieille Indienne}
  # {Old Indian Attack} {Attaque Vieille Indienne}
  # {Old Steinitz} {Vieille Steinitz}
  # {Open Game} {Partie Ouverte}
  # {Poisoned Pawn} {Pion empoisonné}
  # {Polish Variation} {Variante Polonaise}
  # {Polugaevsky Variation} {Variante Polugajewski}
  # {Queen's Gambit} {Gambit Dame}
  # {Queen's Gambit Accepted} {Gambit Dame accepté}
  # QGA {GDA}
  # {Queen's Gambit Accepted (QGA)} {Gambit Dame accepté (GDA)}
  # {Reversed QGA} {GDA inversé}
  # QGD {Gambit Dame Décliné}
  # {Queen's Gambit Declined (QGD)} {Gambit Dame Décliné (GDD)}
  # {Reversed QGD} {GDD inversé}
  # {Queen's Indian} Ouest-Indienne
  # {Queen's Pawn} {Pion Dame}
  # {Queen's Pawn Game} {Partie du Pion Dame}
  # {Reversed Slav} {Slave Inversée}
  # {Rubinstein Variation} {Variante Rubinstein}
  # {Russian Game} {Partie Russe}
  # {Russian Game (Petroff Defence)} {Partie Russe (Défense Petrov)}
  # {Russian-Three Knights Game} {Partie Russe: Trois Cavaliers}
  # {Scandinavian (Centre Counter)} {Scandinave (Centre)}
  # Schliemann Jänisch
  # {Schliemann (Jänisch)} {Gambit Jänisch (Schliemann)}
  # {Scotch Opening} {Ouverture Ecossaise}
  # {Sicilian Defence} {Défense Sicilienne}
  # {Sicilian Variation} {Variante Sicilienne}
  # {Slav Defence} {Défense Slave}
  # Smith-Morra Morra
  # {Smith-Morra Accepted} {Gambit Morra Accepté}
  # {Smith-Morra Gambit} {Gambit Morra}
  # {Spanish (Ruy Lopez)} {Partie Espagnole}
  # {Start position} {Position de départ}
  # {Steinitz Deferred} {Rubinstein retardée}
  # {Swedish Variation} {Variante suédoise}
  # {Swiss Variation} {Variante Suisse}
  # {Tarrasch's Gambit} {Gambit Tarrasch}
  # {Three Knights} {Trois Cavaliers}
  # {3 Knights} {Trois Cavaliers}
  # {Three Knights Game} {Partie des Trois Cavaliers}
  # {Three Pawns Attack} {Attaque des Trois Pions}
  # {Two Knights} {Deux Cavaliers}
  # {Two Knights Defence} {Défense des Deux Cavaliers}
  # {Two Knights Variation} {Variante des Deux Cavaliers}
  # {Two Pawns} {Deux Pions}
  # {Two Pawns Attack} {Attaque des Deux Pions}
  # {Wing Gambit} {Gambit de l'aile}
  # {Yugoslav Attack} {Attaque Yougoslave}
# }


}

# end of francais.tcl
