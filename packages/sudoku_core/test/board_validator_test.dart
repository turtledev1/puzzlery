import 'package:sudoku_core/sudoku_core.dart';
import 'package:test/test.dart';

void main() {
  final validNineByNine = Board.parse('''
123456789
456789123
789123456
234567891
567891234
891234567
345678912
678912345
912345678
''');

  test('a full board with no repeated digit is solved', () {
    expect(BoardValidator.findViolations(validNineByNine), isEmpty);
    expect(BoardValidator.isSolved(validNineByNine), isTrue);
  });

  test('a board with empty cells and no repeated digit has no violation '
      'but is not solved', () {
    final incomplete = validNineByNine.withCell(4, 4, Board.emptyValue);

    expect(BoardValidator.findViolations(incomplete), isEmpty);
    expect(BoardValidator.isSolved(incomplete), isFalse);
  });

  test('a digit twice in a row marks both cells', () {
    final board = Board.empty(9).withCell(0, 0, 5).withCell(0, 8, 5);

    final violations = BoardValidator.findViolations(board);

    expect(violations, hasLength(1));
    expect(violations.single.brokenRule, SudokuRule.uniqueInRow);
    expect(violations.single.cellsInvolved, {
      const CellPosition(0, 0),
      const CellPosition(0, 8),
    });
  });

  test('a digit twice in a column marks both cells', () {
    final board = Board.empty(9).withCell(0, 3, 7).withCell(8, 3, 7);

    final violations = BoardValidator.findViolations(board);

    expect(violations.single.brokenRule, SudokuRule.uniqueInColumn);
  });

  test('a digit twice in a box but not in a line breaks only the box rule', () {
    final board = Board.empty(9).withCell(0, 0, 2).withCell(1, 1, 2);

    final violations = BoardValidator.findViolations(board);

    expect(violations.single.brokenRule, SudokuRule.uniqueInBox);
    expect(BoardValidator.findCellsInViolation(board), {
      const CellPosition(0, 0),
      const CellPosition(1, 1),
    });
  });

  test('on a 6x6 board, boxes are 2 rows by 3 columns', () {
    final sameBoxOfTwoByThree = Board.empty(
      6,
    ).withCell(0, 0, 4).withCell(1, 2, 4);
    final nextBoxOfTwoByThree = Board.empty(
      6,
    ).withCell(0, 0, 4).withCell(1, 3, 4);

    expect(
      BoardValidator.findViolations(sameBoxOfTwoByThree).single.brokenRule,
      SudokuRule.uniqueInBox,
    );
    expect(BoardValidator.findViolations(nextBoxOfTwoByThree), isEmpty);
  });
}
