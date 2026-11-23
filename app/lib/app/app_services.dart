import 'dart:isolate';

import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:flutter/widgets.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

import '../game/binairo_saved_game.dart';
import '../game/sudoku_saved_game.dart';
import '../settings/settings_controller.dart';
import '../statistics/statistics_repository.dart';

typedef BinairoPuzzleFactory =
    Future<binairo.Puzzle> Function(int size, binairo.Difficulty difficulty);

typedef SudokuPuzzleFactory =
    Future<sudoku.Puzzle> Function(int size, sudoku.Difficulty difficulty);

Future<binairo.Puzzle> generateBinairoPuzzleInBackground(
  int size,
  binairo.Difficulty difficulty,
) => Isolate.run(
  () => binairo.PuzzleGenerator().generate(size: size, difficulty: difficulty),
);

Future<sudoku.Puzzle> generateSudokuPuzzleInBackground(
  int size,
  sudoku.Difficulty difficulty,
) => Isolate.run(
  () => sudoku.PuzzleGenerator().generate(size: size, difficulty: difficulty),
);

class AppServices {
  const AppServices({
    required this.statisticsRepository,
    required this.settingsController,
    this.binairoSavedGameRepository = const BinairoSavedGameRepository(),
    this.sudokuSavedGameRepository = const SudokuSavedGameRepository(),
    this.binairoPuzzleFactory = generateBinairoPuzzleInBackground,
    this.sudokuPuzzleFactory = generateSudokuPuzzleInBackground,
  });

  final StatisticsRepository statisticsRepository;
  final SettingsController settingsController;
  final BinairoSavedGameRepository binairoSavedGameRepository;
  final SudokuSavedGameRepository sudokuSavedGameRepository;
  final BinairoPuzzleFactory binairoPuzzleFactory;
  final SudokuPuzzleFactory sudokuPuzzleFactory;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => services != oldWidget.services;
}
