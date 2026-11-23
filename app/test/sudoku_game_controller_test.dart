import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlery_app/game/sudoku_game_controller.dart';
import 'package:puzzlery_app/game/sudoku_game_state.dart';
import 'package:sudoku_core/sudoku_core.dart';

import 'test_puzzles.dart';

void main() {
  late SudokuGameController controller;

  setUp(() {
    controller = SudokuGameController(
      puzzle: fourByFourSudokuPuzzleMissingCells(const [
        CellPosition(0, 0),
        CellPosition(0, 1),
        CellPosition(3, 3),
      ]),
    );
  });

  tearDown(() => controller.dispose());

  void enterDigit(int row, int column, int digit) {
    controller.selectCell(row, column);
    controller.enterDigit(digit);
  }

  void solve() {
    enterDigit(0, 0, 1);
    enterDigit(0, 1, 2);
    enterDigit(3, 3, 1);
  }

  test('a digit goes into the selected cell', () {
    controller.selectCell(0, 0);

    final cellChanged = controller.enterDigit(3);

    expect(cellChanged, isTrue);
    expect(controller.currentBoard.cellAt(0, 0), 3);
  });

  test('without a selected cell, digits do nothing', () {
    expect(controller.canEditSelectedCell, isFalse);

    expect(controller.enterDigit(3), isFalse);

    expect(controller.canUndo, isFalse);
  });

  test('a clue cell can be selected but not changed', () {
    controller.selectCell(1, 1);

    expect(controller.selectedCell, const CellPosition(1, 1));
    expect(controller.canEditSelectedCell, isFalse);
    expect(controller.enterDigit(1), isFalse);
    expect(controller.currentBoard.cellAt(1, 1), 4);
  });

  test('entering the digit the cell already holds is not a move', () {
    enterDigit(0, 0, 3);

    expect(controller.enterDigit(3), isFalse);
    controller.undo();

    expect(controller.currentBoard.cellAt(0, 0), Board.emptyValue);
    expect(controller.canUndo, isFalse);
  });

  test('in notes mode, digits toggle small notes instead of filling the '
      'cell', () {
    controller.selectCell(0, 0);
    controller.toggleNotesMode();

    controller.enterDigit(1);
    controller.enterDigit(3);
    controller.enterDigit(1);

    expect(controller.currentBoard.cellAt(0, 0), Board.emptyValue);
    expect(controller.currentState.notedDigitsAt(0, 0), [3]);
  });

  test('notes cannot go into a cell that holds a digit', () {
    enterDigit(0, 0, 1);
    controller.toggleNotesMode();

    expect(controller.enterDigit(2), isFalse);

    expect(controller.currentState.notedDigitsAt(0, 0), isEmpty);
  });

  test('a digit replaces the notes of its cell', () {
    controller.selectCell(0, 0);
    controller.toggleNotesMode();
    controller.enterDigit(1);
    controller.enterDigit(3);
    controller.toggleNotesMode();

    controller.enterDigit(1);

    expect(controller.currentState.notedDigitsAt(0, 0), isEmpty);
    expect(controller.currentBoard.cellAt(0, 0), 1);
  });

  test('erase clears the digit, then has nothing left to clear', () {
    enterDigit(0, 0, 3);

    expect(controller.eraseSelectedCell(), isTrue);
    expect(controller.currentBoard.cellAt(0, 0), Board.emptyValue);
    expect(controller.eraseSelectedCell(), isFalse);
  });

  test('erase clears the notes of the selected cell', () {
    controller.selectCell(0, 0);
    controller.toggleNotesMode();
    controller.enterDigit(2);

    controller.eraseSelectedCell();

    expect(controller.currentState.notedDigitsAt(0, 0), isEmpty);
  });

  test('undo brings back notes too', () {
    controller.selectCell(0, 0);
    controller.toggleNotesMode();
    controller.enterDigit(2);
    controller.enterDigit(3);

    controller.undo();

    expect(controller.currentState.notedDigitsAt(0, 0), [2]);
  });

  test('selecting a cell or switching notes mode is not a move', () {
    controller.selectCell(0, 0);
    controller.toggleNotesMode();

    expect(controller.canUndo, isFalse);
    expect(controller.canRestart, isFalse);
  });

  test('restart clears digits and notes, and can itself be undone', () {
    enterDigit(0, 0, 1);
    controller.selectCell(0, 1);
    controller.toggleNotesMode();
    controller.enterDigit(2);

    controller.restart();
    expect(
      controller.currentState,
      SudokuGameState.withoutNotes(controller.puzzle.givenBoard),
    );

    controller.undo();
    expect(controller.currentState.notedDigitsAt(0, 1), [2]);
  });

  test('a digit already in the row, column or box is a rule error', () {
    enterDigit(0, 0, 3);

    expect(controller.cellsInViolation, contains(const CellPosition(0, 0)));
    expect(controller.cellsInViolation, contains(const CellPosition(0, 2)));
  });

  test('a full board with every rule kept is solved, and stops input', () {
    solve();

    expect(controller.isSolved, isTrue);
    expect(controller.selectedCell, isNull);
    expect(controller.canUndo, isFalse);
    controller.selectCell(0, 0);
    expect(controller.selectedCell, isNull);
    expect(controller.enterDigit(4), isFalse);
  });

  test('asking for a hint points at a cell without filling it', () {
    controller.requestHint();

    final hint = controller.activeHint;
    expect(hint, isA<DeducibleCellHint>());
    expect(
      controller.currentBoard.cellAtPosition(hint!.cell),
      Board.emptyValue,
    );
    expect(controller.activeHintPointsAtWrongCell, isFalse);
  });

  test('a wrong digit makes the hint point at it, even without a rule '
      'error', () {
    final controllerWithSwappableCells = SudokuGameController(
      puzzle: fourByFourSudokuPuzzleMissingCells(const [
        CellPosition(0, 0),
        CellPosition(0, 2),
        CellPosition(1, 0),
        CellPosition(1, 2),
      ]),
    );
    addTearDown(controllerWithSwappableCells.dispose);
    controllerWithSwappableCells
      ..selectCell(0, 0)
      ..enterDigit(3)
      ..selectCell(1, 0)
      ..enterDigit(1);
    expect(controllerWithSwappableCells.cellsInViolation, isEmpty);

    controllerWithSwappableCells.requestHint();

    expect(controllerWithSwappableCells.activeHint, isA<WrongCellHint>());
    expect(
      controllerWithSwappableCells.activeHint!.cell,
      const CellPosition(0, 0),
    );
    expect(controllerWithSwappableCells.activeHintPointsAtWrongCell, isTrue);
  });

  test('selecting a cell keeps the hint, and a new note clears it', () {
    controller.requestHint();
    controller.selectCell(0, 0);
    expect(controller.activeHint, isNotNull);

    controller.toggleNotesMode();
    controller.enterDigit(1);

    expect(controller.activeHint, isNull);
  });
}
