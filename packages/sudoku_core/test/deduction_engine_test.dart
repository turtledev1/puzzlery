import 'dart:math';

import 'package:sudoku_core/sudoku_core.dart';
import 'package:sudoku_core/src/deduction_engine.dart';
import 'package:test/test.dart';

void main() {
  Board nineByNineWithGivens(Map<(int, int), int> givens) {
    var board = Board.empty(9);
    for (final MapEntry(key: (row, column), value: digit) in givens.entries) {
      board = board.withCell(row, column, digit);
    }
    expect(BoardValidator.findViolations(board), isEmpty);
    return board;
  }

  Set<int> candidatesAfterApplying(
    DeductionRule rule,
    Board board,
    (int, int) cell,
  ) {
    final engine = DeductionEngine.fromBoard(board, {rule});
    engine.applyRule(rule);
    final (row, column) = cell;
    return engine.candidateDigitsAt(row * 9 + column);
  }

  Board transposed(Board board) => Board.fromCells(board.size, [
    for (var row = 0; row < board.size; row++)
      for (var column = 0; column < board.size; column++)
        board.cellAt(column, row),
  ]);

  for (final rule in DeductionRule.values) {
    test('${rule.name} never places or removes a digit that disagrees with a '
        'real solution and never reports a false contradiction', () {
      final random = Random(rule.index);
      for (var round = 0; round < 40; round++) {
        final solution = SolutionGridGenerator(random).generate(9);
        final cellValues = List.of(solution.cells);
        for (var cellIndex = 0; cellIndex < 81; cellIndex++) {
          if (random.nextInt(100) < 65) {
            cellValues[cellIndex] = Board.emptyValue;
          }
        }
        final engine = DeductionEngine(9, cellValues, {rule});

        expect(engine.deduceUntilStuck(), isTrue);
        for (var cellIndex = 0; cellIndex < 81; cellIndex++) {
          final solutionDigit = solution.cells[cellIndex];
          if (engine.cellValues[cellIndex] == Board.emptyValue) {
            expect(
              engine.candidateDigitsAt(cellIndex),
              contains(solutionDigit),
            );
          } else {
            expect(engine.cellValues[cellIndex], solutionDigit);
          }
        }
      }
    });
  }

  test('a hidden single places the only spot for a digit in a box, '
      'even when that cell allows other digits', () {
    final board = nineByNineWithGivens({
      (1, 5): 1,
      (2, 7): 1,
      (5, 1): 1,
      (7, 2): 1,
    });

    expect(
      LogicalSolver({
        DeductionRule.hiddenSingle,
      }).solve(board).board.cellAt(0, 0),
      1,
    );
    expect(
      LogicalSolver({
        DeductionRule.nakedSingle,
      }).solve(board).board.isEmptyAt(0, 0),
      isTrue,
    );
  });

  test('a naked single places the only digit a cell allows', () {
    final board = nineByNineWithGivens({
      (0, 1): 2,
      (0, 2): 3,
      (0, 3): 4,
      (0, 4): 5,
      (3, 0): 6,
      (4, 0): 7,
      (5, 0): 8,
      (6, 0): 9,
    });

    expect(
      LogicalSolver({
        DeductionRule.nakedSingle,
      }).solve(board).board.cellAt(0, 0),
      1,
    );
    expect(
      LogicalSolver({
        DeductionRule.hiddenSingle,
      }).solve(board).board.isEmptyAt(0, 0),
      isTrue,
    );
  });

  test('locked candidates: a digit a box allows only on one row '
      'is removed from the rest of that row', () {
    final rowsOneAndTwoOfBoxZeroFilled = nineByNineWithGivens({
      (1, 0): 2,
      (1, 1): 3,
      (1, 2): 4,
      (2, 0): 5,
      (2, 1): 6,
      (2, 2): 7,
    });

    expect(
      candidatesAfterApplying(
        DeductionRule.lockedCandidates,
        rowsOneAndTwoOfBoxZeroFilled,
        (0, 5),
      ),
      isNot(contains(1)),
    );
  });

  test('locked candidates: a digit a row allows only in one box '
      'is removed from the rest of that box', () {
    final rowZeroFilledOutsideBoxZero = nineByNineWithGivens({
      (0, 3): 2,
      (0, 4): 3,
      (0, 5): 4,
      (0, 6): 5,
      (0, 7): 6,
      (0, 8): 7,
    });

    expect(
      candidatesAfterApplying(
        DeductionRule.lockedCandidates,
        rowZeroFilledOutsideBoxZero,
        (1, 0),
      ),
      isNot(contains(1)),
    );
  });

  test('a naked pair removes its two digits from the rest of the row', () {
    final cellsZeroAndOneAllowOnlyOneAndTwo = nineByNineWithGivens({
      (0, 4): 3,
      (0, 5): 4,
      (0, 6): 5,
      (0, 7): 6,
      (0, 8): 7,
      (3, 0): 8,
      (4, 0): 9,
      (6, 1): 8,
      (7, 1): 9,
    });

    expect(
      candidatesAfterApplying(
        DeductionRule.nakedPair,
        cellsZeroAndOneAllowOnlyOneAndTwo,
        (0, 3),
      ),
      {8, 9},
    );
  });

  test('a hidden pair removes every other digit from its two cells', () {
    final oneAndTwoFitOnlyInTheFirstTwoCellsOfRowZero = nineByNineWithGivens({
      (3, 2): 1,
      (4, 2): 2,
      (1, 3): 1,
      (2, 4): 2,
      (1, 6): 2,
      (2, 7): 1,
    });

    expect(
      candidatesAfterApplying(
        DeductionRule.hiddenPair,
        oneAndTwoFitOnlyInTheFirstTwoCellsOfRowZero,
        (0, 0),
      ),
      {1, 2},
    );
  });

  test('a naked triple removes its three digits from the rest of the row, '
      'where a naked pair finds nothing', () {
    final threeCellsAllowOnlyOneTwoAndThree = nineByNineWithGivens({
      (0, 1): 4,
      (0, 2): 5,
      (0, 4): 6,
      (0, 5): 7,
      (3, 0): 8,
      (6, 0): 9,
      (3, 3): 9,
      (6, 3): 8,
      (4, 6): 8,
      (7, 6): 9,
    });

    expect(
      candidatesAfterApplying(
        DeductionRule.nakedTriple,
        threeCellsAllowOnlyOneTwoAndThree,
        (0, 7),
      ),
      {8, 9},
    );
    expect(
      candidatesAfterApplying(
        DeductionRule.nakedPair,
        threeCellsAllowOnlyOneTwoAndThree,
        (0, 7),
      ),
      {1, 2, 3, 8, 9},
    );
  });

  test('a hidden triple removes every other digit from its three cells', () {
    final oneTwoAndThreeFitOnlyInBoxZeroOfRowZero = nineByNineWithGivens({
      (1, 3): 1,
      (1, 4): 2,
      (2, 5): 3,
      (1, 6): 3,
      (2, 7): 1,
      (2, 8): 2,
    });

    expect(
      candidatesAfterApplying(
        DeductionRule.hiddenTriple,
        oneTwoAndThreeFitOnlyInBoxZeroOfRowZero,
        (0, 0),
      ),
      {1, 2, 3},
    );
  });

  group('x-wing', () {
    Board oneFitsOnlyInColumnsOneAndFourOfRowsOneAndSeven() =>
        nineByNineWithGivens({
          (1, 0): 2,
          (1, 2): 3,
          (1, 3): 4,
          (1, 5): 5,
          (1, 6): 6,
          (1, 7): 7,
          (1, 8): 8,
          (7, 0): 3,
          (7, 2): 2,
          (7, 3): 5,
          (7, 5): 4,
          (7, 6): 8,
          (7, 7): 6,
          (7, 8): 7,
        });

    test('two rows that allow a digit in the same two columns '
        'remove it from the rest of those columns', () {
      expect(
        candidatesAfterApplying(
          DeductionRule.xWing,
          oneFitsOnlyInColumnsOneAndFourOfRowsOneAndSeven(),
          (4, 1),
        ),
        isNot(contains(1)),
      );
    });

    test('two columns that allow a digit in the same two rows '
        'remove it from the rest of those rows', () {
      expect(
        candidatesAfterApplying(
          DeductionRule.xWing,
          transposed(oneFitsOnlyInColumnsOneAndFourOfRowsOneAndSeven()),
          (1, 4),
        ),
        isNot(contains(1)),
      );
    });
  });

  test('a digit repeated in a unit is a contradiction', () {
    final engine = DeductionEngine.fromBoard(
      Board.empty(9).withCell(0, 0, 3).withCell(0, 8, 3),
      DeductionRule.values.toSet(),
    );

    expect(engine.deduceUntilStuck(), isFalse);
  });

  test('a cell that no digit fits is a contradiction', () {
    final engine = DeductionEngine.fromBoard(
      Board.parse('12..\n..3.\n.4..\n....'),
      DeductionRule.values.toSet(),
    );

    expect(engine.deduceUntilStuck(), isFalse);
  });

  test('deduceUntilFirstPlacement stops after one digit', () {
    final engine = DeductionEngine.fromBoard(
      Board.parse('123.\n....\n....\n....'),
      {DeductionRule.nakedSingle},
    );

    expect(engine.deduceUntilFirstPlacement(), 3);
    expect(
      engine.cellValues.where((value) => value != Board.emptyValue),
      hasLength(4),
    );
  });
}
