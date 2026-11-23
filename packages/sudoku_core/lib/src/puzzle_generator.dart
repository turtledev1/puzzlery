import 'dart:math';

import 'board.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';
import 'difficulty.dart';
import 'solution_grid_generator.dart';

class Puzzle {
  const Puzzle({
    required this.difficulty,
    required this.givenBoard,
    required this.solutionBoard,
  });

  final Difficulty difficulty;
  final Board givenBoard;
  final Board solutionBoard;

  int get size => givenBoard.size;
}

/// No uniqueness check is needed: every deduction is forced, so a board that
/// deductions alone can fill has only one solution.
class PuzzleGenerator {
  PuzzleGenerator({Random? random}) : _random = random ?? Random();

  static const int maximumAttemptsToNeedHardDeductions = 20;

  final Random _random;

  Puzzle generate({required int size, required Difficulty difficulty}) {
    late Puzzle lastPuzzle;
    for (
      var attempt = 0;
      attempt < maximumAttemptsToNeedHardDeductions;
      attempt++
    ) {
      lastPuzzle = _generateOnce(size, difficulty);
      if (difficulty.needsMoreThan.isEmpty ||
          !_canSolveWith(
            size,
            lastPuzzle.givenBoard.cells,
            difficulty.needsMoreThan,
          )) {
        return lastPuzzle;
      }
    }
    return lastPuzzle;
  }

  Puzzle _generateOnce(int size, Difficulty difficulty) {
    final solutionBoard = SolutionGridGenerator(_random).generate(size);
    final givenCellValues = List.of(solutionBoard.cells);
    final cellIndexesInRemovalOrder = List.generate(
      givenCellValues.length,
      (index) => index,
    )..shuffle(_random);

    final removedCellIndexes = <int>[];
    for (final cellIndex in cellIndexesInRemovalOrder) {
      final removedDigit = givenCellValues[cellIndex];
      givenCellValues[cellIndex] = Board.emptyValue;
      if (_canSolveWith(size, givenCellValues, difficulty.allowedRules)) {
        removedCellIndexes.add(cellIndex);
      } else {
        givenCellValues[cellIndex] = removedDigit;
      }
    }
    _addCluesBackUntilMinimumShare(
      givenCellValues,
      solutionBoard,
      removedCellIndexes,
      difficulty.minimumClueShare,
    );

    return Puzzle(
      difficulty: difficulty,
      givenBoard: Board.fromCells(size, givenCellValues),
      solutionBoard: solutionBoard,
    );
  }

  /// Adding a clue never blocks a deduction, so the puzzle stays solvable at
  /// its level.
  void _addCluesBackUntilMinimumShare(
    List<int> givenCellValues,
    Board solutionBoard,
    List<int> removedCellIndexes,
    double minimumClueShare,
  ) {
    final minimumClueCount = (givenCellValues.length * minimumClueShare).ceil();
    var clueCount = givenCellValues.length - removedCellIndexes.length;
    removedCellIndexes.shuffle(_random);
    for (final cellIndex in removedCellIndexes) {
      if (clueCount >= minimumClueCount) return;
      givenCellValues[cellIndex] = solutionBoard.cells[cellIndex];
      clueCount++;
    }
  }

  bool _canSolveWith(
    int size,
    List<int> cellValues,
    Set<DeductionRule> allowedRules,
  ) {
    final engine = DeductionEngine(size, List.of(cellValues), allowedRules);
    return engine.deduceUntilStuck() && engine.isComplete;
  }
}
