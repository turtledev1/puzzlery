import 'dart:math';

import 'package:binairo_core/binairo_core.dart';
import 'package:test/test.dart';

void main() {
  final hardTenByTenInProgress = Board.parse('''
1011001001
.......101
.......010
0.....1010
..1....101
.1...0..1.
0..0....0.
.0.10110..
.101.....1
.1.01..1.0
''');

  test('points at the only cell that one line of look-ahead can decide', () {
    final solution = LogicalSolver(
      Difficulty.hard.allowedRules,
    ).solve(hardTenByTenInProgress).board;

    final hint = HintFinder.findHint(
      currentBoard: hardTenByTenInProgress,
      solutionBoard: solution,
    );

    expect(hint, isA<DeducibleCellHint>());
    expect(hint!.cell, const CellPosition(8, 7));
    expect(
      (hint as DeducibleCellHint).rule,
      DeductionRule.lineCompletionLookahead,
    );
  });

  test('prefers the simplest rule when several cells can be decided', () {
    final solution = LogicalSolver(
      Difficulty.hard.allowedRules,
    ).solve(hardTenByTenInProgress).board;
    final onlyAPairOfOnes = Board.empty(
      10,
    ).withCell(0, 2, CellValue.one).withCell(0, 3, CellValue.one);

    final hint = HintFinder.findHint(
      currentBoard: onlyAPairOfOnes,
      solutionBoard: solution,
    );

    expect((hint! as DeducibleCellHint).rule, DeductionRule.adjacentPair);
    expect(hint.cell, const CellPosition(0, 1));
  });

  test('points at a cell the player got wrong before looking for a step', () {
    final solution = Board.parse('0101\n1010\n0110\n1001');
    final boardWithMistake = Board.parse(
      '0...\n....\n..0.\n....',
    ).withCell(2, 2, CellValue.zero);

    final hint = HintFinder.findHint(
      currentBoard: boardWithMistake,
      solutionBoard: solution,
    );

    expect(hint, isA<WrongCellHint>());
    expect(hint!.cell, const CellPosition(2, 2));
  });

  test('a full correct board has no hint', () {
    final solution = Board.parse('0101\n1010\n0110\n1001');

    expect(
      HintFinder.findHint(currentBoard: solution, solutionBoard: solution),
      isNull,
    );
  });

  test('following hints one by one always solves a generated puzzle', () {
    for (final difficulty in Difficulty.values) {
      final puzzle = PuzzleGenerator(
        random: Random(7),
      ).generate(size: 8, difficulty: difficulty);
      var board = puzzle.givenBoard;

      while (!board.isFull) {
        final hint = HintFinder.findHint(
          currentBoard: board,
          solutionBoard: puzzle.solutionBoard,
        );
        expect(hint, isA<DeducibleCellHint>());
        final cell = hint!.cell;
        expect(board.cellAtPosition(cell), CellValue.empty);
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
