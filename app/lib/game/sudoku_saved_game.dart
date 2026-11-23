import 'package:sudoku_core/sudoku_core.dart';

import 'saved_game_repository.dart';
import 'sudoku_game_state.dart';

class SudokuSavedGame implements SavedGameSummary {
  const SudokuSavedGame({
    required this.puzzle,
    required this.currentState,
    required this.elapsed,
    required this.savedAt,
  });

  final Puzzle puzzle;
  final SudokuGameState currentState;
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
    filledCellCount: currentState.board.filledCellCount,
  );
}

class SudokuSavedGameRepository extends SavedGameRepository<SudokuSavedGame> {
  const SudokuSavedGameRepository();

  static const String _difficultyField = 'difficulty';
  static const String _givenBoardField = 'givenBoard';
  static const String _solutionBoardField = 'solutionBoard';
  static const String _currentBoardField = 'currentBoard';
  static const String _noteMasksField = 'noteMasks';
  static const String _elapsedSecondsField = 'elapsedSeconds';
  static const String _savedAtMillisecondsField = 'savedAtMilliseconds';

  @override
  String get storageKey => 'saved_game.sudoku';

  @override
  Map<String, Object> encode(SudokuSavedGame savedGame) => {
    _difficultyField: savedGame.puzzle.difficulty.name,
    _givenBoardField: savedGame.puzzle.givenBoard.toText(),
    _solutionBoardField: savedGame.puzzle.solutionBoard.toText(),
    _currentBoardField: savedGame.currentState.board.toText(),
    _noteMasksField: savedGame.currentState.noteMasks,
    _elapsedSecondsField: savedGame.elapsed.inSeconds,
    _savedAtMillisecondsField: savedGame.savedAt.millisecondsSinceEpoch,
  };

  @override
  SudokuSavedGame decode(Map<String, Object?> json) {
    String field(String key) =>
        SavedGameRepository.requireField<String>(json, key);
    return SudokuSavedGame(
      puzzle: Puzzle(
        difficulty: Difficulty.values.byName(field(_difficultyField)),
        givenBoard: Board.parse(field(_givenBoardField)),
        solutionBoard: Board.parse(field(_solutionBoardField)),
      ),
      currentState: SudokuGameState(
        board: Board.parse(field(_currentBoardField)),
        noteMasks: SavedGameRepository.requireIntList(json, _noteMasksField),
      ),
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
