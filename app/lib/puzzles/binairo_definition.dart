import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../game/binairo_game_controller.dart';
import '../game/binairo_saved_game.dart';
import '../game/game_options.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_labels.dart';
import '../screens/binairo_how_to_play_screen.dart';
import '../settings/settings_controller.dart';
import '../widgets/app_logo.dart';
import '../widgets/binairo_board_grid.dart';
import '../widgets/new_game_sheet.dart';
import 'puzzle_definition.dart';
import 'puzzle_kind.dart';

class BinairoDefinition extends PuzzleDefinition {
  const BinairoDefinition();

  @override
  PuzzleKind get kind => PuzzleKind.binairo;

  @override
  List<int> get boardSizes => binairoBoardSizes;

  @override
  List<Difficulty> get difficulties => Difficulty.values;

  @override
  String difficultyName(AppLocalizations strings, Difficulty difficulty) =>
      strings.binairoDifficultyName(difficulty);

  @override
  Widget buildLogo({required double size}) => AppLogo(size: size);

  @override
  Future<BinairoSavedGame?> loadSavedGame(AppServices services) =>
      services.binairoSavedGameRepository.load();

  @override
  Future<void> saveGame(
    AppServices services,
    BinairoGameController controller,
  ) => services.binairoSavedGameRepository.save(
    BinairoSavedGame(
      puzzle: controller.puzzle,
      currentBoard: controller.currentBoard,
      elapsed: controller.elapsed,
      savedAt: DateTime.now(),
    ),
  );

  @override
  Future<void> clearSavedGame(AppServices services) =>
      services.binairoSavedGameRepository.clear();

  @override
  BinairoGameController resumeGame(BinairoSavedGame savedGame) =>
      BinairoGameController.resume(savedGame);

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
      initialSize: settingsController.settings.binairoLastBoardSize,
      initialDifficulty: settingsController.settings.binairoLastDifficulty,
      difficultyName: strings.binairoDifficultyName,
      difficultyDescription: strings.binairoDifficultyDescription,
    );
    if (choice == null) return null;
    settingsController.update(
      (settings) => settings.copyWith(
        binairoLastBoardSize: choice.size,
        binairoLastDifficulty: choice.difficulty,
      ),
    );
    return () async {
      final puzzle = await services.binairoPuzzleFactory(
        choice.size,
        choice.difficulty,
      );
      return buildGameScreen(BinairoGameController(puzzle: puzzle));
    };
  }

  @override
  Widget buildBoardArea(
    BuildContext context,
    BinairoGameController controller,
    Animation<double> celebration,
  ) {
    final settings = AppScope.of(context).settingsController.settings;
    return Center(
      child: BinairoBoardGrid(
        controller: controller,
        celebration: celebration,
        showRuleErrors: settings.binairoShowRuleErrors,
        showLineCounters: settings.binairoShowLineCounters,
        tapFeedbackEnabled: settings.vibrationEnabled,
      ),
    );
  }

  @override
  Widget buildHowToPlayScreen() => const BinairoHowToPlayScreen();

  @override
  List<Widget> buildPuzzleSettings(
    AppLocalizations strings,
    SettingsController settingsController,
  ) {
    final settings = settingsController.settings;
    return [
      SwitchListTile(
        title: Text(strings.showRuleErrors),
        subtitle: Text(strings.showRuleErrorsDescription),
        value: settings.binairoShowRuleErrors,
        onChanged: (enabled) => settingsController.update(
          (current) => current.copyWith(binairoShowRuleErrors: enabled),
        ),
      ),
      SwitchListTile(
        title: Text(strings.showLineCounters),
        subtitle: Text(strings.showLineCountersDescription),
        value: settings.binairoShowLineCounters,
        onChanged: (enabled) => settingsController.update(
          (current) => current.copyWith(binairoShowLineCounters: enabled),
        ),
      ),
    ];
  }
}
