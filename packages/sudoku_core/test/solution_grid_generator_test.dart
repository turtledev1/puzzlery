import 'dart:math';

import 'package:sudoku_core/sudoku_core.dart';
import 'package:test/test.dart';

void main() {
  for (final size in Board.supportedSizes) {
    test('a generated $size x $size grid is full and breaks no rule', () {
      final grid = SolutionGridGenerator(Random(size)).generate(size);

      expect(grid.size, size);
      expect(BoardValidator.isSolved(grid), isTrue);
    });
  }

  test('different seeds give different grids', () {
    expect(
      SolutionGridGenerator(Random(1)).generate(9),
      isNot(SolutionGridGenerator(Random(2)).generate(9)),
    );
  });
}
