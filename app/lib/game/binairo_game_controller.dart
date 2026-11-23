import 'package:binairo_core/binairo_core.dart';

import '../puzzles/puzzle_kind.dart';
import 'binairo_saved_game.dart';
import 'puzzle_game_controller.dart';

class BinairoGameController extends PuzzleGameController<Board, Hint> {
  BinairoGameController({
    required this.puzzle,
    Board? currentBoard,
    super.elapsedBeforeThisSession,
  }) : super(startingState: puzzle.givenBoard, currentState: currentBoard);

  factory BinairoGameController.resume(BinairoSavedGame savedGame) =>
      BinairoGameController(
        puzzle: savedGame.puzzle,
        currentBoard: savedGame.currentBoard,
        elapsedBeforeThisSession: savedGame.elapsed,
      );

  final Puzzle puzzle;
  Set<CellPosition> _cellsInViolation = const {};

  @override
  PuzzleKind get puzzleKind => PuzzleKind.binairo;

  @override
  int get size => puzzle.size;

  @override
  Difficulty get difficulty => puzzle.difficulty;

  Board get currentBoard => currentState;

  Set<CellPosition> get cellsInViolation => _cellsInViolation;

  bool isGivenCell(int row, int column) =>
      puzzle.givenBoard.cellAt(row, column).isFilled;

  void tapCell(int row, int column) {
    if (isSolved || isGivenCell(row, column)) {
      return;
    }
    final nextValue = currentBoard.cellAt(row, column).nextInTapCycle;
    moveTo(currentBoard.withCell(row, column, nextValue));
  }

  int zerosLeftInRow(int row) =>
      _valuesLeft(currentBoard.row(row), CellValue.zero);

  int onesLeftInRow(int row) =>
      _valuesLeft(currentBoard.row(row), CellValue.one);

  int zerosLeftInColumn(int column) =>
      _valuesLeft(currentBoard.column(column), CellValue.zero);

  int onesLeftInColumn(int column) =>
      _valuesLeft(currentBoard.column(column), CellValue.one);

  int _valuesLeft(List<CellValue> line, CellValue value) =>
      currentBoard.halfSize - line.where((cell) => cell == value).length;

  @override
  bool refreshRuleChecks(Board state) {
    _cellsInViolation = BoardValidator.findCellsInViolation(state);
    return state.isFull && _cellsInViolation.isEmpty;
  }

  @override
  Hint? findHint(Board state) => HintFinder.findHint(
    currentBoard: state,
    solutionBoard: puzzle.solutionBoard,
  );

  @override
  bool isWrongCellHint(Hint hint) => hint is WrongCellHint;
}
