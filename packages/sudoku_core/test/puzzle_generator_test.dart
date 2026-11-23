import 'dart:math';

import 'package:sudoku_core/sudoku_core.dart';
import 'package:test/test.dart';

void main() {
  void expectPuzzleIsFairAndUnique(Puzzle puzzle) {
    final givenBoard = puzzle.givenBoard;
    expect(BoardValidator.isSolved(puzzle.solutionBoard), isTrue);
    for (var row = 0; row < puzzle.size; row++) {
      for (var column = 0; column < puzzle.size; column++) {
        if (!givenBoard.isEmptyAt(row, column)) {
          expect(
            givenBoard.cellAt(row, column),
            puzzle.solutionBoard.cellAt(row, column),
          );
        }
      }
    }
    expect(SolutionCounter.hasExactlyOneSolution(givenBoard), isTrue);
    final logicalResult = LogicalSolver(
      puzzle.difficulty.allowedRules,
    ).solve(givenBoard);
    expect(logicalResult.isSolved, isTrue);
    expect(logicalResult.board, puzzle.solutionBoard);
  }

  for (final difficulty in Difficulty.values) {
    for (final size in Board.supportedSizes) {
      test('a $size x $size ${difficulty.name} puzzle has one solution '
          'reachable with ${difficulty.name} deductions only', () {
        final puzzle = PuzzleGenerator(
          random: Random(size),
        ).generate(size: size, difficulty: difficulty);

        expect(puzzle.size, size);
        expect(puzzle.difficulty, difficulty);
        expectPuzzleIsFairAndUnique(puzzle);
      });
    }
  }

  test('a hard 9x9 puzzle cannot be solved with medium deductions alone', () {
    final puzzle = PuzzleGenerator(
      random: Random(3),
    ).generate(size: 9, difficulty: Difficulty.hard);

    expect(
      LogicalSolver(
        Difficulty.medium.allowedRules,
      ).canSolveCompletely(puzzle.givenBoard),
      isFalse,
    );
  });

  for (final size in Board.supportedSizes) {
    test('an easy $size x $size puzzle starts with at least 45% of the cells '
        'as clues, more than a medium one', () {
      final easyPuzzle = PuzzleGenerator(
        random: Random(5),
      ).generate(size: size, difficulty: Difficulty.easy);
      final mediumPuzzle = PuzzleGenerator(
        random: Random(5),
      ).generate(size: size, difficulty: Difficulty.medium);

      expect(
        easyPuzzle.givenBoard.filledCellCount,
        greaterThanOrEqualTo((size * size * 0.45).ceil()),
      );
      expect(
        easyPuzzle.givenBoard.filledCellCount,
        greaterThan(mediumPuzzle.givenBoard.filledCellCount),
      );
    });
  }

  test('removing any one more clue from a medium puzzle makes it unsolvable at '
      'its level', () {
    final puzzle = PuzzleGenerator(
      random: Random(5),
    ).generate(size: 9, difficulty: Difficulty.medium);
    final solver = LogicalSolver(Difficulty.medium.allowedRules);

    for (var row = 0; row < 9; row++) {
      for (var column = 0; column < 9; column++) {
        if (puzzle.givenBoard.isEmptyAt(row, column)) continue;
        final boardWithOneLessClue = puzzle.givenBoard.withCell(
          row,
          column,
          Board.emptyValue,
        );
        expect(solver.canSolveCompletely(boardWithOneLessClue), isFalse);
      }
    }
  });

  test('the same seed gives the same puzzle', () {
    Puzzle generateWithSeed(int seed) => PuzzleGenerator(
      random: Random(seed),
    ).generate(size: 9, difficulty: Difficulty.hard);

    expect(generateWithSeed(42).givenBoard, generateWithSeed(42).givenBoard);
  });

  group('stress', tags: 'slow', () {
    for (final difficulty in Difficulty.values) {
      for (final size in Board.supportedSizes) {
        test(
          '200 ${difficulty.name} $size x $size puzzles are all fair and unique',
          () {
            final generator = PuzzleGenerator(random: Random(1000 + size));
            for (var puzzleNumber = 0; puzzleNumber < 200; puzzleNumber++) {
              expectPuzzleIsFairAndUnique(
                generator.generate(size: size, difficulty: difficulty),
              );
            }
          },
        );
      }
    }
  });
}
