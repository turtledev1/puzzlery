import 'package:sudoku_core/sudoku_core.dart';

import '../puzzles/puzzle_kind.dart';
import 'puzzle_game_controller.dart';
import 'sudoku_game_state.dart';
import 'sudoku_saved_game.dart';

class SudokuGameController extends PuzzleGameController<SudokuGameState, Hint> {
  SudokuGameController({
    required this.puzzle,
    super.currentState,
    super.elapsedBeforeThisSession,
  }) : super(startingState: SudokuGameState.withoutNotes(puzzle.givenBoard));

  factory SudokuGameController.resume(SudokuSavedGame savedGame) =>
      SudokuGameController(
        puzzle: savedGame.puzzle,
        currentState: savedGame.currentState,
        elapsedBeforeThisSession: savedGame.elapsed,
      );

  final Puzzle puzzle;
  Set<CellPosition> _cellsInViolation = const {};
  CellPosition? _selectedCell;
  bool _isNotesMode = false;

  @override
  PuzzleKind get puzzleKind => PuzzleKind.sudoku;

  @override
  int get size => puzzle.size;

  @override
  Difficulty get difficulty => puzzle.difficulty;

  Board get currentBoard => currentState.board;

  Set<CellPosition> get cellsInViolation => _cellsInViolation;

  CellPosition? get selectedCell => _selectedCell;

  bool get isNotesMode => _isNotesMode;

  bool get canEditSelectedCell {
    final selectedCell = _selectedCell;
    return !isSolved &&
        selectedCell != null &&
        !isGivenCell(selectedCell.row, selectedCell.column);
  }

  bool isGivenCell(int row, int column) =>
      !puzzle.givenBoard.isEmptyAt(row, column);

  void selectCell(int row, int column) {
    final tappedCell = CellPosition(row, column);
    if (isSolved || _selectedCell == tappedCell) {
      return;
    }
    _selectedCell = tappedCell;
    notifyListeners();
  }

  void toggleNotesMode() {
    if (isSolved) {
      return;
    }
    _isNotesMode = !_isNotesMode;
    notifyListeners();
  }

  /// Returns whether the selected cell changed.
  bool enterDigit(int digit) {
    if (!canEditSelectedCell) {
      return false;
    }
    final CellPosition(:row, :column) = _selectedCell!;
    if (_isNotesMode) {
      if (!currentBoard.isEmptyAt(row, column)) {
        return false;
      }
      moveTo(currentState.withNoteToggled(row, column, digit));
      return true;
    }
    if (currentBoard.cellAt(row, column) == digit) {
      return false;
    }
    moveTo(currentState.withDigit(row, column, digit));
    return true;
  }

  /// Returns whether the selected cell changed.
  bool eraseSelectedCell() {
    if (!canEditSelectedCell) {
      return false;
    }
    final CellPosition(:row, :column) = _selectedCell!;
    if (currentBoard.isEmptyAt(row, column) &&
        !currentState.hasNotesAt(row, column)) {
      return false;
    }
    moveTo(currentState.withCellCleared(row, column));
    return true;
  }

  @override
  bool refreshRuleChecks(SudokuGameState state) {
    _cellsInViolation = BoardValidator.findCellsInViolation(state.board);
    final isSolved = state.board.isFull && _cellsInViolation.isEmpty;
    if (isSolved) {
      _selectedCell = null;
    }
    return isSolved;
  }

  @override
  Hint? findHint(SudokuGameState state) => HintFinder.findHint(
    currentBoard: state.board,
    solutionBoard: puzzle.solutionBoard,
  );

  @override
  bool isWrongCellHint(Hint hint) => hint is WrongCellHint;
}
