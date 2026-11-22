import 'dart:math';

import 'board.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';

class SolutionGridGenerator {
  SolutionGridGenerator(this._random);

  final Random _random;

  Board generate(int size) {
    final solvedCellValues = _fillRandomly(
      size,
      List.of(Board.empty(size).cells),
    );
    if (solvedCellValues == null) {
      throw StateError('No valid board exists for size $size.');
    }
    return Board.fromCells(size, solvedCellValues);
  }

  List<int>? _fillRandomly(int size, List<int> cellValues) {
    final engine = DeductionEngine(size, cellValues, {
      DeductionRule.hiddenSingle,
      DeductionRule.nakedSingle,
    });
    if (!engine.deduceUntilStuck()) {
      return null;
    }
    final cellsWithFewestCandidates = engine.emptyCellsWithFewestCandidates();
    if (cellsWithFewestCandidates.isEmpty) {
      return cellValues;
    }
    final chosenCellIndex =
        cellsWithFewestCandidates[_random.nextInt(
          cellsWithFewestCandidates.length,
        )];
    final digitsInTryOrder = engine.candidateDigitsAt(chosenCellIndex).toList()
      ..shuffle(_random);
    for (final digit in digitsInTryOrder) {
      final cellValuesWithChoice = List.of(cellValues);
      cellValuesWithChoice[chosenCellIndex] = digit;
      final filled = _fillRandomly(size, cellValuesWithChoice);
      if (filled != null) {
        return filled;
      }
    }
    return null;
  }
}
