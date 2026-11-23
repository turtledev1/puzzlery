import 'package:binairo_core/binairo_core.dart';
import 'package:puzzlery_app/settings/app_settings.dart';
import 'package:puzzlery_app/settings/settings_controller.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('first launch uses the defaults', () async {
    final settings = (await SettingsController.load()).settings;

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.language, AppLanguage.phone);
    expect(settings.vibrationEnabled, isTrue);
    expect(settings.autoHintEnabled, isFalse);
    expect(settings.autoHintDelay, const Duration(minutes: 1));
    expect(settings.binairoShowRuleErrors, isTrue);
    expect(settings.binairoShowLineCounters, isTrue);
    expect(settings.binairoLastBoardSize, 8);
    expect(settings.binairoLastDifficulty, Difficulty.easy);
    expect(settings.sudokuShowRuleErrors, isTrue);
    expect(settings.sudokuLastBoardSize, 9);
    expect(settings.sudokuLastDifficulty, sudoku.Difficulty.easy);
  });

  test('changed settings are still there after the app restarts', () async {
    final controller = await SettingsController.load();

    await controller.update(
      (settings) => settings.copyWith(
        themeMode: ThemeMode.dark,
        language: AppLanguage.french,
        vibrationEnabled: false,
        autoHintEnabled: true,
        autoHintDelay: const Duration(seconds: 30),
        binairoShowRuleErrors: false,
        binairoShowLineCounters: false,
        binairoLastBoardSize: 12,
        binairoLastDifficulty: Difficulty.hard,
        sudokuShowRuleErrors: false,
        sudokuLastBoardSize: 4,
        sudokuLastDifficulty: sudoku.Difficulty.hard,
      ),
    );
    final reloaded = (await SettingsController.load()).settings;

    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.language, AppLanguage.french);
    expect(reloaded.vibrationEnabled, isFalse);
    expect(reloaded.autoHintEnabled, isTrue);
    expect(reloaded.autoHintDelay, const Duration(seconds: 30));
    expect(reloaded.binairoShowRuleErrors, isFalse);
    expect(reloaded.binairoShowLineCounters, isFalse);
    expect(reloaded.binairoLastBoardSize, 12);
    expect(reloaded.binairoLastDifficulty, Difficulty.hard);
    expect(reloaded.sudokuShowRuleErrors, isFalse);
    expect(reloaded.sudokuLastBoardSize, 4);
    expect(reloaded.sudokuLastDifficulty, sudoku.Difficulty.hard);
  });

  test('updating notifies listeners so the screens rebuild', () async {
    final controller = await SettingsController.load();
    var notificationCount = 0;
    controller.addListener(() => notificationCount++);

    await controller.update(
      (settings) => settings.copyWith(vibrationEnabled: false),
    );

    expect(notificationCount, 1);
  });

  test('unknown saved values fall back to the defaults', () async {
    SharedPreferences.setMockInitialValues({
      'settings.theme_mode': 'purple',
      'settings.language': 'klingon',
      'settings.binairo.last_board_size': 7,
      'settings.binairo.last_difficulty': 'impossible',
      'settings.sudoku.last_board_size': 8,
      'settings.sudoku.last_difficulty': 'impossible',
    });

    final settings = (await SettingsController.load()).settings;

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.language, AppLanguage.phone);
    expect(settings.binairoLastBoardSize, 8);
    expect(settings.binairoLastDifficulty, Difficulty.easy);
    expect(settings.sudokuLastBoardSize, 9);
    expect(settings.sudokuLastDifficulty, sudoku.Difficulty.easy);
  });
}
