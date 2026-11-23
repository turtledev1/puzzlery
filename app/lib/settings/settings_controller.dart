import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

import '../game/game_options.dart';
import 'app_settings.dart';

class SettingsController extends ChangeNotifier {
  SettingsController._(this._settings);

  static const String _themeModeKey = 'settings.theme_mode';
  static const String _languageKey = 'settings.language';
  static const String _vibrationEnabledKey = 'settings.vibration_enabled';
  static const String _autoHintEnabledKey = 'settings.auto_hint_enabled';
  static const String _autoHintDelaySecondsKey =
      'settings.auto_hint_delay_seconds';
  static const String _binairoShowRuleErrorsKey =
      'settings.binairo.show_rule_errors';
  static const String _binairoShowLineCountersKey =
      'settings.binairo.show_line_counters';
  static const String _binairoLastBoardSizeKey =
      'settings.binairo.last_board_size';
  static const String _binairoLastDifficultyKey =
      'settings.binairo.last_difficulty';
  static const String _sudokuShowRuleErrorsKey =
      'settings.sudoku.show_rule_errors';
  static const String _sudokuLastBoardSizeKey =
      'settings.sudoku.last_board_size';
  static const String _sudokuLastDifficultyKey =
      'settings.sudoku.last_difficulty';

  static Future<SettingsController> load() async {
    final preferences = await SharedPreferences.getInstance();
    const defaults = AppSettings();
    final savedAutoHintDelay = Duration(
      seconds: preferences.getInt(_autoHintDelaySecondsKey) ?? -1,
    );
    int boardSizeOrDefault(String key, List<int> sizes, int defaultSize) {
      final savedSize = preferences.getInt(key);
      return sizes.contains(savedSize) ? savedSize! : defaultSize;
    }

    return SettingsController._(
      AppSettings(
        themeMode: _enumByNameOrDefault(
          ThemeMode.values,
          preferences.getString(_themeModeKey),
          defaults.themeMode,
        ),
        language: _enumByNameOrDefault(
          AppLanguage.values,
          preferences.getString(_languageKey),
          defaults.language,
        ),
        vibrationEnabled:
            preferences.getBool(_vibrationEnabledKey) ??
            defaults.vibrationEnabled,
        autoHintEnabled:
            preferences.getBool(_autoHintEnabledKey) ??
            defaults.autoHintEnabled,
        autoHintDelay:
            AppSettings.autoHintDelayChoices.contains(savedAutoHintDelay)
            ? savedAutoHintDelay
            : defaults.autoHintDelay,
        binairoShowRuleErrors:
            preferences.getBool(_binairoShowRuleErrorsKey) ??
            defaults.binairoShowRuleErrors,
        binairoShowLineCounters:
            preferences.getBool(_binairoShowLineCountersKey) ??
            defaults.binairoShowLineCounters,
        binairoLastBoardSize: boardSizeOrDefault(
          _binairoLastBoardSizeKey,
          binairoBoardSizes,
          defaults.binairoLastBoardSize,
        ),
        binairoLastDifficulty: _enumByNameOrDefault(
          binairo.Difficulty.values,
          preferences.getString(_binairoLastDifficultyKey),
          defaults.binairoLastDifficulty,
        ),
        sudokuShowRuleErrors:
            preferences.getBool(_sudokuShowRuleErrorsKey) ??
            defaults.sudokuShowRuleErrors,
        sudokuLastBoardSize: boardSizeOrDefault(
          _sudokuLastBoardSizeKey,
          sudokuBoardSizes,
          defaults.sudokuLastBoardSize,
        ),
        sudokuLastDifficulty: _enumByNameOrDefault(
          sudoku.Difficulty.values,
          preferences.getString(_sudokuLastDifficultyKey),
          defaults.sudokuLastDifficulty,
        ),
      ),
    );
  }

  AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> update(AppSettings Function(AppSettings current) change) async {
    _settings = change(_settings);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_themeModeKey, _settings.themeMode.name);
    await preferences.setString(_languageKey, _settings.language.name);
    await preferences.setBool(_vibrationEnabledKey, _settings.vibrationEnabled);
    await preferences.setBool(_autoHintEnabledKey, _settings.autoHintEnabled);
    await preferences.setInt(
      _autoHintDelaySecondsKey,
      _settings.autoHintDelay.inSeconds,
    );
    await preferences.setBool(
      _binairoShowRuleErrorsKey,
      _settings.binairoShowRuleErrors,
    );
    await preferences.setBool(
      _binairoShowLineCountersKey,
      _settings.binairoShowLineCounters,
    );
    await preferences.setInt(
      _binairoLastBoardSizeKey,
      _settings.binairoLastBoardSize,
    );
    await preferences.setString(
      _binairoLastDifficultyKey,
      _settings.binairoLastDifficulty.name,
    );
    await preferences.setBool(
      _sudokuShowRuleErrorsKey,
      _settings.sudokuShowRuleErrors,
    );
    await preferences.setInt(
      _sudokuLastBoardSizeKey,
      _settings.sudokuLastBoardSize,
    );
    await preferences.setString(
      _sudokuLastDifficultyKey,
      _settings.sudokuLastDifficulty.name,
    );
  }

  static T _enumByNameOrDefault<T extends Enum>(
    List<T> values,
    String? name,
    T defaultValue,
  ) => values.where((value) => value.name == name).firstOrNull ?? defaultValue;
}
