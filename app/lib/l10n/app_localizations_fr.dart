// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Puzzlery';

  @override
  String get binairoName => 'Binairo';

  @override
  String get binairoTagline => 'Un casse-tête logique de zéros et de uns';

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get makingPuzzle => 'Création de votre grille…';

  @override
  String get howToPlay => 'Comment jouer';

  @override
  String get statistics => 'Statistiques';

  @override
  String get settings => 'Paramètres';

  @override
  String get continueGame => 'Continuer';

  @override
  String percentFilled(int percent) {
    return '$percent %';
  }

  @override
  String get replaceSavedGameTitle => 'Commencer une nouvelle partie?';

  @override
  String get replaceSavedGameMessage => 'Votre partie en cours sera perdue.';

  @override
  String get replaceSavedGameConfirm => 'Nouvelle partie';

  @override
  String get cancel => 'Annuler';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get difficultyEasyDescription =>
      'Étapes simples seulement : paires, trous et décompte des lignes.';

  @override
  String get difficultyHardDescription =>
      'Il faut anticiper pour compléter chaque ligne.';

  @override
  String get boardSize => 'Taille';

  @override
  String get difficultyLevel => 'Niveau';

  @override
  String get start => 'Commencer';

  @override
  String get wrongCellHint =>
      'La case qui brille ne convient pas. Changez-la d\'abord.';

  @override
  String get solvedTitle => 'Résolu!';

  @override
  String newBestTime(String time) {
    return 'Nouveau record : $time';
  }

  @override
  String solveTime(String time) {
    return 'Temps : $time';
  }

  @override
  String get lookAtBoard => 'Voir la grille';

  @override
  String get home => 'Accueil';

  @override
  String get restartTitle => 'Recommencer la grille?';

  @override
  String get restartMessage => 'Tous vos coups seront effacés.';

  @override
  String get restart => 'Recommencer';

  @override
  String get hint => 'Indice';

  @override
  String get undo => 'Annuler le coup';

  @override
  String get menu => 'Menu';

  @override
  String get howToPlayIntro => 'Remplissez chaque case vide avec un 0 ou un 1.';

  @override
  String ruleCardTitle(int number, String title) {
    return 'Règle $number · $title';
  }

  @override
  String get ruleNoThreeInARowTitle => 'Pas trois à la suite';

  @override
  String get ruleNoThreeInARowExplanation =>
      'Trois valeurs identiques ne peuvent pas se suivre dans une ligne ou une colonne.';

  @override
  String get ruleBalancedLinesTitle => 'Autant de 0 que de 1';

  @override
  String get ruleBalancedLinesExplanation =>
      'Chaque ligne et chaque colonne a autant de 0 que de 1.';

  @override
  String get ruleUniqueLinesTitle => 'Pas deux lignes identiques';

  @override
  String get ruleUniqueLinesExplanation =>
      'Deux lignes complètes ne peuvent pas être identiques. Deux colonnes complètes non plus.';

  @override
  String get exampleCorrect => 'Correct';

  @override
  String get exampleWrong => 'Incorrect';

  @override
  String get controlsTitle => 'Commandes';

  @override
  String get controlTapCell =>
      'Touchez une case vide pour mettre un 0. Touchez-la encore pour un 1. Touchez-la une troisième fois pour l\'effacer.';

  @override
  String get controlClues =>
      'Les cases grises sont fixes. Vous ne pouvez pas les changer.';

  @override
  String get controlRuleErrors =>
      'Un contour rouge montre une case qui ne respecte pas une règle.';

  @override
  String get controlLineCounters =>
      'Les petits nombres à côté de chaque ligne et colonne montrent combien de 0 (orange) et de 1 (bleu) il manque encore.';

  @override
  String get controlHint =>
      'Bloqué? Touchez Indice dans le menu ⋮. Une lueur jaune montre une case que vous pouvez trouver avec les règles. Elle ne montre jamais le chiffre.';

  @override
  String get controlUndo =>
      'Touchez Annuler le coup pour reprendre votre dernier coup.';

  @override
  String get resetStatisticsTitle => 'Réinitialiser les statistiques?';

  @override
  String get resetStatisticsMessage =>
      'Tous les nombres de grilles résolues et tous les temps seront supprimés.';

  @override
  String get resetStatisticsTooltip => 'Réinitialiser les statistiques';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get statisticsSolvedCount => 'Résolues';

  @override
  String get statisticsBestTime => 'Record';

  @override
  String get statisticsAverageTime => 'Moyenne';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get followPhone => 'Téléphone';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get settingsGame => 'Jeu';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationDescription =>
      'Vibre quand vous touchez une case et quand vous résolvez une grille';

  @override
  String get showRuleErrors => 'Afficher les erreurs';

  @override
  String get showRuleErrorsDescription =>
      'Contour rouge sur les cases qui ne respectent pas une règle';

  @override
  String get showLineCounters => 'Afficher les compteurs';

  @override
  String get showLineCountersDescription =>
      'Nombre de 0 et de 1 qui manquent encore dans chaque ligne et colonne';

  @override
  String get autoHint => 'Indice automatique';

  @override
  String get autoHintDescription =>
      'Quand vous arrêtez un moment, une case que vous pouvez trouver s\'illumine';

  @override
  String delayInSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String delayInMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsAbout => 'À propos';

  @override
  String puzzleSettingsTitle(String puzzle) {
    return 'Paramètres de $puzzle';
  }

  @override
  String get allSettings => 'Tous les paramètres';

  @override
  String get allSettingsDescription =>
      'Apparence, vibration, indice automatique et langue';
}
