import 'package:flutter/material.dart';
import 'package:sudoku_core/sudoku_core.dart';

import '../app/app_services.dart';
import '../game/game_options.dart';
import '../game/sudoku_game_controller.dart';
import '../game/sudoku_saved_game.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_labels.dart';
import '../screens/sudoku_how_to_play_screen.dart';
import '../settings/settings_controller.dart';
import '../widgets/new_game_sheet.dart';
import '../widgets/sudoku_board_grid.dart';
import '../widgets/sudoku_logo.dart';
import '../widgets/sudoku_number_pad.dart';
import 'puzzle_definition.dart';
import 'puzzle_kind.dart';

class SudokuDefinition extends PuzzleDefinition {
  const SudokuDefinition();

  @override
  PuzzleKind get kind => PuzzleKind.sudoku;

  @override
  List<int> get boardSizes => sudokuBoardSizes;

  @override
  List<Difficulty> get difficulties => Difficulty.values;

  @override
  String difficultyName(AppLocalizations strings, Difficulty difficulty) =>
      strings.sudokuDifficultyName(difficulty);

  @override
  Widget buildLogo({required double size}) => SudokuLogo(size: size);

  @override
  Future<SudokuSavedGame?> loadSavedGame(AppServices services) =>
      services.sudokuSavedGameRepository.load();

  @override
  Future<void> saveGame(
    AppServices services,
    SudokuGameController controller,
  ) => services.sudokuSavedGameRepository.save(
    SudokuSavedGame(
      puzzle: controller.puzzle,
      currentState: controller.currentState,
      elapsed: controller.elapsed,
      savedAt: DateTime.now(),
    ),
  );

  @override
  Future<void> clearSavedGame(AppServices services) =>
      services.sudokuSavedGameRepository.clear();

  @override
  SudokuGameController resumeGame(SudokuSavedGame savedGame) =>
      SudokuGameController.resume(savedGame);

  @override
  Future<GameScreenFactory?> chooseNewGame(
    BuildContext context,
    AppServices services,
  ) async {
    final settingsController = services.settingsController;
    final strings = context.strings;
    final choice = await showNewGameSheet(
      context,
      boardSizes: boardSizes,
      difficulties: difficulties,
      initialSize: settingsController.settings.sudokuLastBoardSize,
      initialDifficulty: settingsController.settings.sudokuLastDifficulty,
      difficultyName: strings.sudokuDifficultyName,
      difficultyDescription: strings.sudokuDifficultyDescription,
    );
    if (choice == null) return null;
    settingsController.update(
      (settings) => settings.copyWith(
        sudokuLastBoardSize: choice.size,
        sudokuLastDifficulty: choice.difficulty,
      ),
    );
    return () async {
      final puzzle = await services.sudokuPuzzleFactory(
        choice.size,
        choice.difficulty,
      );
      return buildGameScreen(SudokuGameController(puzzle: puzzle));
    };
  }

  @override
  Widget buildBoardArea(
    BuildContext context,
    SudokuGameController controller,
    Animation<double> celebration,
  ) {
    final settings = AppScope.of(context).settingsController.settings;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: SudokuBoardGrid(
              controller: controller,
              celebration: celebration,
              showRuleErrors: settings.sudokuShowRuleErrors,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SudokuNumberPad(
          controller: controller,
          tapFeedbackEnabled: settings.vibrationEnabled,
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget buildHowToPlayScreen() => const SudokuHowToPlayScreen();

  @override
  List<Widget> buildPuzzleSettings(
    AppLocalizations strings,
    SettingsController settingsController,
  ) => [
    SwitchListTile(
      title: Text(strings.showRuleErrors),
      subtitle: Text(strings.showRuleErrorsDescription),
      value: settingsController.settings.sudokuShowRuleErrors,
      onChanged: (enabled) => settingsController.update(
        (current) => current.copyWith(sudokuShowRuleErrors: enabled),
      ),
    ),
  ];
}
