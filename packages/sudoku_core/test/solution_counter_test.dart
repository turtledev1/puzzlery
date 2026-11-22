import 'package:sudoku_core/sudoku_core.dart';
import 'package:test/test.dart';

void main() {
  test('a full valid board has exactly one solution', () {
    expect(
      SolutionCounter.countSolutions(Board.parse('1234\n3412\n2143\n4321')),
      1,
    );
  });

  test('a full board with a repeated digit has no solution', () {
    expect(
      SolutionCounter.countSolutions(Board.parse('1234\n3412\n2143\n4312')),
      0,
    );
  });

  test('an empty board has many solutions and counting stops at the limit', () {
    expect(
      SolutionCounter.countSolutions(Board.empty(9), stopCountingAt: 5),
      5,
    );
    expect(SolutionCounter.hasExactlyOneSolution(Board.empty(9)), isFalse);
  });

  test('the number of 4x4 solutions matches the known total of 288', () {
    expect(
      SolutionCounter.countSolutions(Board.empty(4), stopCountingAt: 1000),
      288,
    );
  });

  test('a board with a cell that no digit fits has no solution', () {
    expect(
      SolutionCounter.countSolutions(Board.parse('12..\n..3.\n.4..\n....')),
      0,
    );
  });
}
