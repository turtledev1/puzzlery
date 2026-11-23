import 'package:flutter/widgets.dart';

import '../app/app_services.dart';
import '../game/puzzle_game_controller.dart';
import '../game/saved_game_repository.dart';
import '../l10n/app_localizations.dart';
import '../screens/puzzle_game_screen.dart';
import '../screens/puzzle_settings_screen.dart';
import '../screens/statistics_screen.dart';
import '../settings/settings_controller.dart';
import 'binairo_definition.dart';
import 'puzzle_kind.dart';
import 'sudoku_definition.dart';

typedef AnyPuzzleGameController = PuzzleGameController<Object, Object>;

typedef GameScreenFactory = Future<Widget> Function();

/// Parameters marked `covariant` receive only this puzzle's own types.
abstract class PuzzleDefinition {
  const PuzzleDefinition();

  PuzzleKind get kind;

  List<int> get boardSizes;

  List<Enum> get difficulties;

  String difficultyName(AppLocalizations strings, covariant Enum difficulty);

  Widget buildLogo({required double size});

  Future<SavedGameSummary?> loadSavedGame(AppServices services);

  Future<void> saveGame(
    AppServices services,
    covariant AnyPuzzleGameController controller,
  );

  Future<void> clearSavedGame(AppServices services);

  AnyPuzzleGameController resumeGame(covariant SavedGameSummary savedGame);

  /// Returns `null` when the player cancels.
  Future<GameScreenFactory?> chooseNewGame(
    BuildContext context,
    AppServices services,
  );

  Widget buildBoardArea(
    BuildContext context,
    covariant AnyPuzzleGameController controller,
    Animation<double> celebration,
  );

  Widget buildHowToPlayScreen();

  List<Widget> buildPuzzleSettings(
    AppLocalizations strings,
    SettingsController settingsController,
  );

  Widget buildGameScreen(AnyPuzzleGameController controller) =>
      PuzzleGameScreen(definition: this, controller: controller);

  Widget buildSettingsScreen() => PuzzleSettingsScreen(definition: this);

  Widget buildStatisticsScreen() => StatisticsScreen(definition: this);
}

extension PuzzleKindDefinition on PuzzleKind {
  PuzzleDefinition get definition => switch (this) {
    PuzzleKind.binairo => const BinairoDefinition(),
    PuzzleKind.sudoku => const SudokuDefinition(),
  };
}
