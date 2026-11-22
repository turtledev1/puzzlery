import 'board.dart';
import 'cell_position.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';

sealed class Hint {
  const Hint(this.cell);

  final CellPosition cell;
}

/// A cell whose value follows from one [rule] applied to one line.
class DeducibleCellHint extends Hint {
  const DeducibleCellHint(super.cell, this.rule);

  final DeductionRule rule;
}

class WrongCellHint extends Hint {
  const WrongCellHint(super.cell);
}

abstract final class HintFinder {
  /// Returns `null` when the board is full and correct.
  static Hint? findHint({
    required Board currentBoard,
    required Board solutionBoard,
  }) {
    final wrongCell = _firstWrongCell(currentBoard, solutionBoard);
    if (wrongCell != null) {
      return WrongCellHint(wrongCell);
    }
    final size = currentBoard.size;
    final currentCellCodes = cellCodesFromBoard(currentBoard);
    for (final rule in DeductionRule.values) {
      for (var lineIndex = 0; lineIndex < size * 2; lineIndex++) {
        final cellCodesAfterOneStep = List.of(currentCellCodes);
        DeductionEngine(size, cellCodesAfterOneStep, {
          rule,
        }).applyRuleOnLine(rule, lineIndex);
        for (var cellIndex = 0; cellIndex < size * size; cellIndex++) {
          final wasFilledByThisStep =
              currentCellCodes[cellIndex] == emptyCellCode &&
              cellCodesAfterOneStep[cellIndex] != emptyCellCode;
          if (wasFilledByThisStep) {
            return DeducibleCellHint(
              CellPosition(cellIndex ~/ size, cellIndex % size),
              rule,
            );
          }
        }
      }
    }
    return null;
  }

  static CellPosition? _firstWrongCell(
    Board currentBoard,
    Board solutionBoard,
  ) {
    for (var row = 0; row < currentBoard.size; row++) {
      for (var column = 0; column < currentBoard.size; column++) {
        final currentValue = currentBoard.cellAt(row, column);
        if (currentValue.isFilled &&
            currentValue != solutionBoard.cellAt(row, column)) {
          return CellPosition(row, column);
        }
      }
    }
    return null;
  }
}
