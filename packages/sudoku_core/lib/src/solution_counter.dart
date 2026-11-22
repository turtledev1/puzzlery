import 'board.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';

abstract final class SolutionCounter {
  static int countSolutions(Board board, {int stopCountingAt = 2}) =>
      _countSolutions(board.size, List.of(board.cells), stopCountingAt);

  static bool hasExactlyOneSolution(Board board) =>
      countSolutions(board, stopCountingAt: 2) == 1;

  static int _countSolutions(
    int size,
    List<int> cellValues,
    int stopCountingAt,
  ) {
    final engine = DeductionEngine(size, cellValues, {
      DeductionRule.hiddenSingle,
      DeductionRule.nakedSingle,
    });
    if (!engine.deduceUntilStuck()) {
      return 0;
    }
    final branchCells = engine.emptyCellsWithFewestCandidates();
    if (branchCells.isEmpty) {
      return 1;
    }
    final branchCellIndex = branchCells.first;
    var solutionsFound = 0;
    for (final guessedDigit in engine.candidateDigitsAt(branchCellIndex)) {
      final cellValuesWithGuess = List.of(cellValues);
      cellValuesWithGuess[branchCellIndex] = guessedDigit;
      solutionsFound += _countSolutions(
        size,
        cellValuesWithGuess,
        stopCountingAt - solutionsFound,
      );
      if (solutionsFound >= stopCountingAt) {
        break;
      }
    }
    return solutionsFound;
  }
}
