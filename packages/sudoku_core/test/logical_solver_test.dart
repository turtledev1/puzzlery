import 'dart:math';

import 'package:sudoku_core/sudoku_core.dart';
import 'package:test/test.dart';

void main() {
  test('easy rules solve an easy puzzle to its solution', () {
    final puzzle = PuzzleGenerator(
      random: Random(11),
    ).generate(size: 9, difficulty: Difficulty.easy);

    final result = LogicalSolver(
      Difficulty.easy.allowedRules,
    ).solve(puzzle.givenBoard);

    expect(result.isSolved, isTrue);
    expect(result.hasContradiction, isFalse);
    expect(result.board, puzzle.solutionBoard);
  });

  test('easy rules get stuck on a hard puzzle without a contradiction, '
      'and hard rules finish it', () {
    final puzzle = PuzzleGenerator(
      random: Random(12),
    ).generate(size: 9, difficulty: Difficulty.hard);

    final easyResult = LogicalSolver(
      Difficulty.easy.allowedRules,
    ).solve(puzzle.givenBoard);
    final hardResult = LogicalSolver(
      Difficulty.hard.allowedRules,
    ).solve(puzzle.givenBoard);

    expect(easyResult.isSolved, isFalse);
    expect(easyResult.hasContradiction, isFalse);
    expect(hardResult.board, puzzle.solutionBoard);
  });

  test('a board with a repeated digit reports a contradiction', () {
    final result = LogicalSolver(
      Difficulty.hard.allowedRules,
    ).solve(Board.empty(9).withCell(0, 0, 5).withCell(1, 1, 5));

    expect(result.hasContradiction, isTrue);
    expect(result.isSolved, isFalse);
  });

  test('the solver does not change the board it was given', () {
    final board = Board.parse('123.\n....\n....\n....');

    LogicalSolver(Difficulty.hard.allowedRules).solve(board);

    expect(board.toText(), '123.\n....\n....\n....');
  });
}
