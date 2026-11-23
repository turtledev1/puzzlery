import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/widgets.dart';

import '../puzzles/puzzle_kind.dart';
import 'app_localizations.dart';

extension LocalizedStrings on BuildContext {
  AppLocalizations get strings => AppLocalizations.of(this);
}

extension DifficultyLabels on AppLocalizations {
  String difficultyName(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => difficultyEasy,
    Difficulty.hard => difficultyHard,
  };

  String difficultyDescription(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => difficultyEasyDescription,
    Difficulty.hard => difficultyHardDescription,
  };
}

extension PuzzleKindLabels on AppLocalizations {
  String puzzleName(PuzzleKind puzzleKind) => switch (puzzleKind) {
    PuzzleKind.binairo => binairoName,
  };

  String puzzleTagline(PuzzleKind puzzleKind) => switch (puzzleKind) {
    PuzzleKind.binairo => binairoTagline,
  };
}
