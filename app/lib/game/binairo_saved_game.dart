import 'package:binairo_core/binairo_core.dart';

import 'saved_game_repository.dart';

class BinairoSavedGame implements SavedGameSummary {
  const BinairoSavedGame({
    required this.puzzle,
    required this.currentBoard,
    required this.elapsed,
    required this.savedAt,
  });

  final Puzzle puzzle;
  final Board currentBoard;
  @override
  final Duration elapsed;
  @override
  final DateTime savedAt;

  @override
  int get size => puzzle.size;

  @override
  Difficulty get difficulty => puzzle.difficulty;

  @override
  double get fillProgress => fillProgressOf(
    cellCount: puzzle.size * puzzle.size,
    givenCellCount: puzzle.givenBoard.filledCellCount,
    filledCellCount: currentBoard.filledCellCount,
  );
}

class BinairoSavedGameRepository extends SavedGameRepository<BinairoSavedGame> {
  const BinairoSavedGameRepository();

  static const String _difficultyField = 'difficulty';
  static const String _givenBoardField = 'givenBoard';
  static const String _solutionBoardField = 'solutionBoard';
  static const String _currentBoardField = 'currentBoard';
  static const String _elapsedSecondsField = 'elapsedSeconds';
  static const String _savedAtMillisecondsField = 'savedAtMilliseconds';

  @override
  String get storageKey => 'saved_game.binairo';

  @override
  Map<String, Object> encode(BinairoSavedGame savedGame) => {
    _difficultyField: savedGame.puzzle.difficulty.name,
    _givenBoardField: savedGame.puzzle.givenBoard.toText(),
    _solutionBoardField: savedGame.puzzle.solutionBoard.toText(),
    _currentBoardField: savedGame.currentBoard.toText(),
    _elapsedSecondsField: savedGame.elapsed.inSeconds,
    _savedAtMillisecondsField: savedGame.savedAt.millisecondsSinceEpoch,
  };

  @override
  BinairoSavedGame decode(Map<String, Object?> json) {
    String field(String key) =>
        SavedGameRepository.requireField<String>(json, key);
    return BinairoSavedGame(
      puzzle: Puzzle(
        difficulty: Difficulty.values.byName(field(_difficultyField)),
        givenBoard: Board.parse(field(_givenBoardField)),
        solutionBoard: Board.parse(field(_solutionBoardField)),
      ),
      currentBoard: Board.parse(field(_currentBoardField)),
      elapsed: Duration(
        seconds: SavedGameRepository.requireField<int>(
          json,
          _elapsedSecondsField,
        ),
      ),
      savedAt: DateTime.fromMillisecondsSinceEpoch(
        SavedGameRepository.requireField<int>(json, _savedAtMillisecondsField),
      ),
    );
  }
}
