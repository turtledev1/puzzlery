import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:flutter/widgets.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

import '../puzzles/puzzle_kind.dart';
import 'app_localizations.dart';

extension LocalizedStrings on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}

extension DifficultyLabels on AppLocalizations {
  String binairoDifficultyName(binairo.Difficulty difficulty) =>
      switch (difficulty) {
        binairo.Difficulty.easy => difficultyEasy,
        binairo.Difficulty.hard => difficultyHard,
      };

  String binairoDifficultyDescription(binairo.Difficulty difficulty) =>
      switch (difficulty) {
        binairo.Difficulty.easy => binairoDifficultyEasyDescription,
        binairo.Difficulty.hard => binairoDifficultyHardDescription,
      };

  String sudokuDifficultyName(sudoku.Difficulty difficulty) =>
      switch (difficulty) {
        sudoku.Difficulty.easy => difficultyEasy,
        sudoku.Difficulty.hard => difficultyHard,
      };

  String sudokuDifficultyDescription(sudoku.Difficulty difficulty) =>
      switch (difficulty) {
        sudoku.Difficulty.easy => sudokuDifficultyEasyDescription,
        sudoku.Difficulty.hard => sudokuDifficultyHardDescription,
      };
}

extension PuzzleKindLabels on AppLocalizations {
  String puzzleName(PuzzleKind puzzleKind) => switch (puzzleKind) {
    PuzzleKind.binairo => binairoName,
    PuzzleKind.sudoku => sudokuName,
  };

  String puzzleTagline(PuzzleKind puzzleKind) => switch (puzzleKind) {
    PuzzleKind.binairo => binairoTagline,
    PuzzleKind.sudoku => sudokuTagline,
  };
}
