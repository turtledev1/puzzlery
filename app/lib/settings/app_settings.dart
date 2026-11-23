import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:flutter/material.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

enum AppLanguage {
  phone(null),
  english(Locale('en')),
  french(Locale('fr'));

  const AppLanguage(this.locale);

  final Locale? locale;
}

class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.phone,
    this.vibrationEnabled = true,
    this.autoHintEnabled = false,
    this.autoHintDelay = const Duration(minutes: 1),
    this.binairoShowRuleErrors = true,
    this.binairoShowLineCounters = true,
    this.binairoLastBoardSize = 8,
    this.binairoLastDifficulty = binairo.Difficulty.easy,
    this.sudokuShowRuleErrors = true,
    this.sudokuLastBoardSize = 9,
    this.sudokuLastDifficulty = sudoku.Difficulty.easy,
  });

  static const List<Duration> autoHintDelayChoices = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
  ];

  final ThemeMode themeMode;
  final AppLanguage language;
  final bool vibrationEnabled;
  final bool autoHintEnabled;
  final Duration autoHintDelay;
  final bool binairoShowRuleErrors;
  final bool binairoShowLineCounters;
  final int binairoLastBoardSize;
  final binairo.Difficulty binairoLastDifficulty;
  final bool sudokuShowRuleErrors;
  final int sudokuLastBoardSize;
  final sudoku.Difficulty sudokuLastDifficulty;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? vibrationEnabled,
    bool? autoHintEnabled,
    Duration? autoHintDelay,
    bool? binairoShowRuleErrors,
    bool? binairoShowLineCounters,
    int? binairoLastBoardSize,
    binairo.Difficulty? binairoLastDifficulty,
    bool? sudokuShowRuleErrors,
    int? sudokuLastBoardSize,
    sudoku.Difficulty? sudokuLastDifficulty,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    autoHintEnabled: autoHintEnabled ?? this.autoHintEnabled,
    autoHintDelay: autoHintDelay ?? this.autoHintDelay,
    binairoShowRuleErrors: binairoShowRuleErrors ?? this.binairoShowRuleErrors,
    binairoShowLineCounters:
        binairoShowLineCounters ?? this.binairoShowLineCounters,
    binairoLastBoardSize: binairoLastBoardSize ?? this.binairoLastBoardSize,
    binairoLastDifficulty: binairoLastDifficulty ?? this.binairoLastDifficulty,
    sudokuShowRuleErrors: sudokuShowRuleErrors ?? this.sudokuShowRuleErrors,
    sudokuLastBoardSize: sudokuLastBoardSize ?? this.sudokuLastBoardSize,
    sudokuLastDifficulty: sudokuLastDifficulty ?? this.sudokuLastDifficulty,
  );
}
