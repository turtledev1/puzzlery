import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Puzzlery'**
  String get appTitle;

  /// No description provided for @binairoName.
  ///
  /// In en, this message translates to:
  /// **'Binairo'**
  String get binairoName;

  /// No description provided for @binairoTagline.
  ///
  /// In en, this message translates to:
  /// **'A logic puzzle of zeros and ones'**
  String get binairoTagline;

  /// No description provided for @sudokuName.
  ///
  /// In en, this message translates to:
  /// **'Sudoku'**
  String get sudokuName;

  /// No description provided for @sudokuTagline.
  ///
  /// In en, this message translates to:
  /// **'A logic puzzle of rows, columns and boxes'**
  String get sudokuTagline;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get newGame;

  /// No description provided for @makingPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Making your puzzle…'**
  String get makingPuzzle;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @continueGame.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueGame;

  /// No description provided for @percentFilled.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String percentFilled(int percent);

  /// No description provided for @replaceSavedGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new game?'**
  String get replaceSavedGameTitle;

  /// No description provided for @replaceSavedGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Your unfinished game will be lost.'**
  String get replaceSavedGameMessage;

  /// No description provided for @replaceSavedGameConfirm.
  ///
  /// In en, this message translates to:
  /// **'Start new game'**
  String get replaceSavedGameConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get difficultyMedium;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @boardSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get boardSize;

  /// No description provided for @difficultyLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get difficultyLevel;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @wrongCellHint.
  ///
  /// In en, this message translates to:
  /// **'The glowing cell does not fit. Change it first.'**
  String get wrongCellHint;

  /// No description provided for @solvedTitle.
  ///
  /// In en, this message translates to:
  /// **'Solved!'**
  String get solvedTitle;

  /// No description provided for @newBestTime.
  ///
  /// In en, this message translates to:
  /// **'New best time: {time}'**
  String newBestTime(String time);

  /// No description provided for @solveTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String solveTime(String time);

  /// No description provided for @lookAtBoard.
  ///
  /// In en, this message translates to:
  /// **'Look at board'**
  String get lookAtBoard;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @restartTitle.
  ///
  /// In en, this message translates to:
  /// **'Restart puzzle?'**
  String get restartTitle;

  /// No description provided for @restartMessage.
  ///
  /// In en, this message translates to:
  /// **'This clears all your moves.'**
  String get restartMessage;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @hint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @howToPlayIntro.
  ///
  /// In en, this message translates to:
  /// **'Fill every empty cell with a 0 or a 1.'**
  String get howToPlayIntro;

  /// No description provided for @ruleCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Rule {number} · {title}'**
  String ruleCardTitle(int number, String title);

  /// No description provided for @ruleNoThreeInARowTitle.
  ///
  /// In en, this message translates to:
  /// **'No three in a row'**
  String get ruleNoThreeInARowTitle;

  /// No description provided for @ruleNoThreeInARowExplanation.
  ///
  /// In en, this message translates to:
  /// **'Three equal values cannot touch in a row or a column.'**
  String get ruleNoThreeInARowExplanation;

  /// No description provided for @ruleBalancedLinesTitle.
  ///
  /// In en, this message translates to:
  /// **'Same number of 0s and 1s'**
  String get ruleBalancedLinesTitle;

  /// No description provided for @ruleBalancedLinesExplanation.
  ///
  /// In en, this message translates to:
  /// **'Every row and every column has as many 0s as 1s.'**
  String get ruleBalancedLinesExplanation;

  /// No description provided for @ruleUniqueLinesTitle.
  ///
  /// In en, this message translates to:
  /// **'No two lines the same'**
  String get ruleUniqueLinesTitle;

  /// No description provided for @ruleUniqueLinesExplanation.
  ///
  /// In en, this message translates to:
  /// **'Two full rows cannot be equal. Two full columns cannot be equal.'**
  String get ruleUniqueLinesExplanation;

  /// No description provided for @exampleCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get exampleCorrect;

  /// No description provided for @exampleWrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get exampleWrong;

  /// No description provided for @controlsTitle.
  ///
  /// In en, this message translates to:
  /// **'Controls'**
  String get controlsTitle;

  /// No description provided for @controlTapCell.
  ///
  /// In en, this message translates to:
  /// **'Tap an empty cell to put a 0. Tap again for a 1. Tap a third time to clear it.'**
  String get controlTapCell;

  /// No description provided for @controlClues.
  ///
  /// In en, this message translates to:
  /// **'Gray cells are clues. You cannot change them.'**
  String get controlClues;

  /// No description provided for @controlRuleErrors.
  ///
  /// In en, this message translates to:
  /// **'A red ring shows a cell that breaks a rule.'**
  String get controlRuleErrors;

  /// No description provided for @controlLineCounters.
  ///
  /// In en, this message translates to:
  /// **'The small numbers next to each row and column show how many 0s (orange) and 1s (blue) are still missing.'**
  String get controlLineCounters;

  /// No description provided for @controlHint.
  ///
  /// In en, this message translates to:
  /// **'Stuck? Tap Hint in the ⋮ menu. A yellow glow shows a cell you can figure out with the rules. It never shows the number.'**
  String get controlHint;

  /// No description provided for @controlUndo.
  ///
  /// In en, this message translates to:
  /// **'Use Undo to take back your last move.'**
  String get controlUndo;

  /// No description provided for @sudokuHowToPlayIntro.
  ///
  /// In en, this message translates to:
  /// **'Fill every empty cell with a digit: 1 to 9 on a 9×9 board, 1 to 6 on 6×6, 1 to 4 on 4×4.'**
  String get sudokuHowToPlayIntro;

  /// No description provided for @sudokuRuleRowTitle.
  ///
  /// In en, this message translates to:
  /// **'Once in each row'**
  String get sudokuRuleRowTitle;

  /// No description provided for @sudokuRuleRowExplanation.
  ///
  /// In en, this message translates to:
  /// **'Each digit is in every row one time.'**
  String get sudokuRuleRowExplanation;

  /// No description provided for @sudokuRuleColumnTitle.
  ///
  /// In en, this message translates to:
  /// **'Once in each column'**
  String get sudokuRuleColumnTitle;

  /// No description provided for @sudokuRuleColumnExplanation.
  ///
  /// In en, this message translates to:
  /// **'Each digit is in every column one time.'**
  String get sudokuRuleColumnExplanation;

  /// No description provided for @sudokuRuleBoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Once in each box'**
  String get sudokuRuleBoxTitle;

  /// No description provided for @sudokuRuleBoxExplanation.
  ///
  /// In en, this message translates to:
  /// **'Each digit is in every box one time. Thick lines show the boxes.'**
  String get sudokuRuleBoxExplanation;

  /// No description provided for @sudokuControlEnterDigit.
  ///
  /// In en, this message translates to:
  /// **'Tap a cell, then tap a digit below the board.'**
  String get sudokuControlEnterDigit;

  /// No description provided for @sudokuControlNotes.
  ///
  /// In en, this message translates to:
  /// **'Tap Notes to write small digits that could fit. Tap Notes again to write normal digits.'**
  String get sudokuControlNotes;

  /// No description provided for @sudokuControlErase.
  ///
  /// In en, this message translates to:
  /// **'Tap Erase to clear the cell.'**
  String get sudokuControlErase;

  /// No description provided for @sudokuControlClues.
  ///
  /// In en, this message translates to:
  /// **'Bold digits are clues. You cannot change them.'**
  String get sudokuControlClues;

  /// No description provided for @sudokuNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get sudokuNotes;

  /// No description provided for @sudokuErase.
  ///
  /// In en, this message translates to:
  /// **'Erase'**
  String get sudokuErase;

  /// No description provided for @resetStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics?'**
  String get resetStatisticsTitle;

  /// No description provided for @resetStatisticsMessage.
  ///
  /// In en, this message translates to:
  /// **'All solve counts and times will be deleted.'**
  String get resetStatisticsMessage;

  /// No description provided for @resetStatisticsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Reset statistics'**
  String get resetStatisticsTooltip;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @statisticsSolvedCount.
  ///
  /// In en, this message translates to:
  /// **'Solved'**
  String get statisticsSolvedCount;

  /// No description provided for @statisticsBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get statisticsBestTime;

  /// No description provided for @statisticsAverageTime.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get statisticsAverageTime;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @followPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get followPhone;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageNameFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageNameFrench;

  /// No description provided for @settingsGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get settingsGame;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrationDescription.
  ///
  /// In en, this message translates to:
  /// **'Buzz when you tap a cell and when you solve a puzzle'**
  String get vibrationDescription;

  /// No description provided for @showRuleErrors.
  ///
  /// In en, this message translates to:
  /// **'Show rule errors'**
  String get showRuleErrors;

  /// No description provided for @showRuleErrorsDescription.
  ///
  /// In en, this message translates to:
  /// **'Red ring on cells that break a rule'**
  String get showRuleErrorsDescription;

  /// No description provided for @showLineCounters.
  ///
  /// In en, this message translates to:
  /// **'Show counters'**
  String get showLineCounters;

  /// No description provided for @showLineCountersDescription.
  ///
  /// In en, this message translates to:
  /// **'0s and 1s still missing in each row and column'**
  String get showLineCountersDescription;

  /// No description provided for @autoHint.
  ///
  /// In en, this message translates to:
  /// **'Auto-hint'**
  String get autoHint;

  /// No description provided for @autoHintDescription.
  ///
  /// In en, this message translates to:
  /// **'When you stop for a while, a cell you can figure out glows'**
  String get autoHintDescription;

  /// No description provided for @delayInSeconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String delayInSeconds(int seconds);

  /// No description provided for @delayInMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String delayInMinutes(int minutes);

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @puzzleSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'{puzzle} settings'**
  String puzzleSettingsTitle(String puzzle);

  /// No description provided for @allSettings.
  ///
  /// In en, this message translates to:
  /// **'All settings'**
  String get allSettings;

  /// No description provided for @allSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Appearance, vibration, auto-hint and language'**
  String get allSettingsDescription;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
