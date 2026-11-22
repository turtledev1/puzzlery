import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

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
    this.showRuleErrors = true,
    this.showLineCounters = true,
    this.lastBoardSize = 8,
    this.lastDifficulty = Difficulty.easy,
    this.autoHintEnabled = false,
    this.autoHintDelay = const Duration(minutes: 1),
  });

  static const List<Duration> autoHintDelayChoices = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
  ];

  final ThemeMode themeMode;
  final AppLanguage language;
  final bool vibrationEnabled;
  final bool showRuleErrors;
  final bool showLineCounters;
  final int lastBoardSize;
  final Difficulty lastDifficulty;
  final bool autoHintEnabled;
  final Duration autoHintDelay;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? vibrationEnabled,
    bool? showRuleErrors,
    bool? showLineCounters,
    int? lastBoardSize,
    Difficulty? lastDifficulty,
    bool? autoHintEnabled,
    Duration? autoHintDelay,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    showRuleErrors: showRuleErrors ?? this.showRuleErrors,
    showLineCounters: showLineCounters ?? this.showLineCounters,
    lastBoardSize: lastBoardSize ?? this.lastBoardSize,
    lastDifficulty: lastDifficulty ?? this.lastDifficulty,
    autoHintEnabled: autoHintEnabled ?? this.autoHintEnabled,
    autoHintDelay: autoHintDelay ?? this.autoHintDelay,
  );
}
