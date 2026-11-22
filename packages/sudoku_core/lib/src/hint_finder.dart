import 'board.dart';
import 'cell_position.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';

sealed class Hint {
  const Hint(this.cell);

  final CellPosition cell;
}

/// [rule] is the hardest rule needed to reach [cell].
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
    final allowedRulesSoFar = <DeductionRule>{};
    for (final rule in DeductionRule.values) {
      allowedRulesSoFar.add(rule);
      final placedCellIndex = DeductionEngine.fromBoard(
        currentBoard,
        allowedRulesSoFar,
      ).deduceUntilFirstPlacement();
      if (placedCellIndex != null) {
        return DeducibleCellHint(
          CellPosition(placedCellIndex ~/ size, placedCellIndex % size),
          rule,
        );
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
        if (currentValue != Board.emptyValue &&
            currentValue != solutionBoard.cellAt(row, column)) {
          return CellPosition(row, column);
        }
      }
    }
    return null;
  }
}
