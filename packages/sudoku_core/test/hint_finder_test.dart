import 'dart:math';

import 'package:sudoku_core/sudoku_core.dart';
import 'package:test/test.dart';

void main() {
  final validFourByFour = Board.parse('1234\n3412\n2143\n4321');

  test('prefers the simplest rule when several cells can be decided', () {
    final lastCellOfRowZeroIsMissing = validFourByFour.withCell(
      0,
      3,
      Board.emptyValue,
    );

    final hint = HintFinder.findHint(
      currentBoard: lastCellOfRowZeroIsMissing,
      solutionBoard: validFourByFour,
    );

    expect(hint, isA<DeducibleCellHint>());
    expect(hint!.cell, const CellPosition(0, 3));
    expect((hint as DeducibleCellHint).rule, DeductionRule.hiddenSingle);
  });

  test('points at a cell the player got wrong before looking for a step', () {
    final boardWithMistake = Board.empty(4).withCell(2, 2, 1);

    final hint = HintFinder.findHint(
      currentBoard: boardWithMistake,
      solutionBoard: validFourByFour,
    );

    expect(hint, isA<WrongCellHint>());
    expect(hint!.cell, const CellPosition(2, 2));
  });

  test('a full correct board has no hint', () {
    expect(
      HintFinder.findHint(
        currentBoard: validFourByFour,
        solutionBoard: validFourByFour,
      ),
      isNull,
    );
  });

  test('when singles are stuck, the hint names the harder rule it needs', () {
    final puzzle = PuzzleGenerator(
      random: Random(12),
    ).generate(size: 9, difficulty: Difficulty.hard);
    final stuckAfterSingles = LogicalSolver(
      Difficulty.easy.allowedRules,
    ).solve(puzzle.givenBoard).board;

    final hint = HintFinder.findHint(
      currentBoard: stuckAfterSingles,
      solutionBoard: puzzle.solutionBoard,
    );

    expect(hint, isA<DeducibleCellHint>());
    expect(stuckAfterSingles.cellAtPosition(hint!.cell), Board.emptyValue);
    expect(
      Difficulty.easy.allowedRules,
      isNot(contains((hint as DeducibleCellHint).rule)),
    );
  });

  test('following hints one by one always solves a generated puzzle', () {
    for (final difficulty in Difficulty.values) {
      final puzzle = PuzzleGenerator(
        random: Random(7),
      ).generate(size: 9, difficulty: difficulty);
      var board = puzzle.givenBoard;

      while (!board.isFull) {
        final hint = HintFinder.findHint(
          currentBoard: board,
          solutionBoard: puzzle.solutionBoard,
        );
        expect(hint, isA<DeducibleCellHint>());
        final cell = hint!.cell;
        expect(board.cellAtPosition(cell), Board.emptyValue);
        board = board.withCell(
          cell.row,
          cell.column,
          puzzle.solutionBoard.cellAtPosition(cell),
        );
      }

      expect(board, puzzle.solutionBoard);
    }
  });
}
