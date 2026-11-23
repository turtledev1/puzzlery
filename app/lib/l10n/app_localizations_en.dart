// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Puzzlery';

  @override
  String get binairoName => 'Binairo';

  @override
  String get binairoTagline => 'A logic puzzle of zeros and ones';

  @override
  String get newGame => 'New game';

  @override
  String get makingPuzzle => 'Making your puzzle…';

  @override
  String get howToPlay => 'How to play';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get continueGame => 'Continue';

  @override
  String percentFilled(int percent) {
    return '$percent%';
  }

  @override
  String get replaceSavedGameTitle => 'Start a new game?';

  @override
  String get replaceSavedGameMessage => 'Your unfinished game will be lost.';

  @override
  String get replaceSavedGameConfirm => 'Start new game';

  @override
  String get cancel => 'Cancel';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get difficultyEasyDescription =>
      'Simple steps only: pairs, gaps and line counts.';

  @override
  String get difficultyHardDescription =>
      'You need to look ahead to finish each line.';

  @override
  String get boardSize => 'Size';

  @override
  String get difficultyLevel => 'Level';

  @override
  String get start => 'Start';

  @override
  String get wrongCellHint => 'The glowing cell does not fit. Change it first.';

  @override
  String get solvedTitle => 'Solved!';

  @override
  String newBestTime(String time) {
    return 'New best time: $time';
  }

  @override
  String solveTime(String time) {
    return 'Time: $time';
  }

  @override
  String get lookAtBoard => 'Look at board';

  @override
  String get home => 'Home';

  @override
  String get restartTitle => 'Restart puzzle?';

  @override
  String get restartMessage => 'This clears all your moves.';

  @override
  String get restart => 'Restart';

  @override
  String get hint => 'Hint';

  @override
  String get undo => 'Undo';

  @override
  String get menu => 'Menu';

  @override
  String get howToPlayIntro => 'Fill every empty cell with a 0 or a 1.';

  @override
  String ruleCardTitle(int number, String title) {
    return 'Rule $number · $title';
  }

  @override
  String get ruleNoThreeInARowTitle => 'No three in a row';

  @override
  String get ruleNoThreeInARowExplanation =>
      'Three equal values cannot touch in a row or a column.';

  @override
  String get ruleBalancedLinesTitle => 'Same number of 0s and 1s';

  @override
  String get ruleBalancedLinesExplanation =>
      'Every row and every column has as many 0s as 1s.';

  @override
  String get ruleUniqueLinesTitle => 'No two lines the same';

  @override
  String get ruleUniqueLinesExplanation =>
      'Two full rows cannot be equal. Two full columns cannot be equal.';

  @override
  String get exampleCorrect => 'Correct';

  @override
  String get exampleWrong => 'Wrong';

  @override
  String get controlsTitle => 'Controls';

  @override
  String get controlTapCell =>
      'Tap an empty cell to put a 0. Tap again for a 1. Tap a third time to clear it.';

  @override
  String get controlClues => 'Gray cells are clues. You cannot change them.';

  @override
  String get controlRuleErrors => 'A red ring shows a cell that breaks a rule.';

  @override
  String get controlLineCounters =>
      'The small numbers next to each row and column show how many 0s (orange) and 1s (blue) are still missing.';

  @override
  String get controlHint =>
      'Stuck? Tap Hint in the ⋮ menu. A yellow glow shows a cell you can figure out with the rules. It never shows the number.';

  @override
  String get controlUndo => 'Use Undo to take back your last move.';

  @override
  String get resetStatisticsTitle => 'Reset statistics?';

  @override
  String get resetStatisticsMessage =>
      'All solve counts and times will be deleted.';

  @override
  String get resetStatisticsTooltip => 'Reset statistics';

  @override
  String get reset => 'Reset';

  @override
  String get statisticsSolvedCount => 'Solved';

  @override
  String get statisticsBestTime => 'Best';

  @override
  String get statisticsAverageTime => 'Average';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get followPhone => 'Phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameFrench => 'Français';

  @override
  String get settingsGame => 'Game';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrationDescription =>
      'Buzz when you tap a cell and when you solve a puzzle';

  @override
  String get showRuleErrors => 'Show rule errors';

  @override
  String get showRuleErrorsDescription => 'Red ring on cells that break a rule';

  @override
  String get showLineCounters => 'Show counters';

  @override
  String get showLineCountersDescription =>
      '0s and 1s still missing in each row and column';

  @override
  String get autoHint => 'Auto-hint';

  @override
  String get autoHintDescription =>
      'When you stop for a while, a cell you can figure out glows';

  @override
  String delayInSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String delayInMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get settingsAbout => 'About';

  @override
  String puzzleSettingsTitle(String puzzle) {
    return '$puzzle settings';
  }

  @override
  String get allSettings => 'All settings';

  @override
  String get allSettingsDescription =>
      'Appearance, vibration, auto-hint and language';
}
