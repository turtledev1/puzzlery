import 'board.dart';
import 'board_geometry.dart';
import 'cell_position.dart';

enum SudokuRule { uniqueInRow, uniqueInColumn, uniqueInBox }

class RuleViolation {
  const RuleViolation(this.brokenRule, this.cellsInvolved);

  final SudokuRule brokenRule;
  final Set<CellPosition> cellsInvolved;

  @override
  String toString() => 'RuleViolation($brokenRule, $cellsInvolved)';
}

abstract final class BoardValidator {
  static List<RuleViolation> findViolations(Board board) {
    final geometry = BoardGeometry.forSize(board.size);
    return [
      ..._findRepeatedDigits(board, geometry.rows, SudokuRule.uniqueInRow),
      ..._findRepeatedDigits(
        board,
        geometry.columns,
        SudokuRule.uniqueInColumn,
      ),
      ..._findRepeatedDigits(board, geometry.boxes, SudokuRule.uniqueInBox),
    ];
  }

  static Set<CellPosition> findCellsInViolation(Board board) => {
    for (final violation in findViolations(board)) ...violation.cellsInvolved,
  };

  static bool isSolved(Board board) =>
      board.isFull && findViolations(board).isEmpty;

  static Iterable<RuleViolation> _findRepeatedDigits(
    Board board,
    List<List<int>> units,
    SudokuRule ruleOfUnits,
  ) sync* {
    for (final unit in units) {
      final cellsByDigit = <int, List<int>>{};
      for (final cell in unit) {
        final digit = board.cells[cell];
        if (digit == Board.emptyValue) continue;
        cellsByDigit.putIfAbsent(digit, () => []).add(cell);
      }
      for (final cellsWithSameDigit in cellsByDigit.values) {
        if (cellsWithSameDigit.length < 2) continue;
        yield RuleViolation(ruleOfUnits, {
          for (final cell in cellsWithSameDigit)
            CellPosition(cell ~/ board.size, cell % board.size),
        });
      }
    }
  }
}
