import 'package:sudoku_core/sudoku_core.dart';
import 'package:test/test.dart';

void main() {
  test('parse and toText round-trip, with dots for empty cells', () {
    const text = '1.3.\n..1.\n2...\n...4';

    expect(Board.parse(text).toText(), text);
  });

  test('parse reads 0 as an empty cell', () {
    expect(
      Board.parse('1000\n0000\n0000\n0000').toText(),
      '1...\n....\n....\n....',
    );
  });

  test('only sizes 4, 6 and 9 are supported', () {
    expect(Board.supportedSizes, [4, 6, 9]);
    expect(() => Board.empty(5), throwsArgumentError);
    expect(() => Board.empty(16), throwsArgumentError);
  });

  test('a 6x6 board has boxes of 2 rows by 3 columns', () {
    final board = Board.empty(6);

    expect(board.boxHeight, 2);
    expect(board.boxWidth, 3);
    expect(board.boxIndexOf(0, 2), 0);
    expect(board.boxIndexOf(0, 3), 1);
    expect(board.boxIndexOf(2, 0), 2);
    expect(board.boxIndexOf(5, 5), 5);
  });

  test('a 9x9 board has boxes of 3 rows by 3 columns', () {
    final board = Board.empty(9);

    expect(board.boxHeight, 3);
    expect(board.boxWidth, 3);
    expect(board.boxIndexOf(4, 4), 4);
    expect(board.boxIndexOf(8, 0), 6);
  });

  test('digits larger than the size are rejected', () {
    expect(() => Board.parse('5...\n....\n....\n....'), throwsArgumentError);
    expect(() => Board.empty(4).withCell(0, 0, 5), throwsArgumentError);
  });

  test('a row of the wrong length or an unknown character is rejected', () {
    expect(() => Board.parse('1...\n...\n....\n....'), throwsFormatException);
    expect(() => Board.parse('x...\n....\n....\n....'), throwsFormatException);
  });

  test('withCell returns a new board and leaves the original unchanged', () {
    final original = Board.empty(4);
    final updated = original.withCell(1, 2, 3);

    expect(original.cellAt(1, 2), Board.emptyValue);
    expect(updated.cellAt(1, 2), 3);
    expect(updated.isEmptyAt(1, 2), isFalse);
  });

  test('boards with the same cells are equal', () {
    expect(
      Board.parse('12..\n....\n....\n....'),
      Board.empty(4).withCell(0, 0, 1).withCell(0, 1, 2),
    );
  });

  test('isFull and filledCellCount follow the cells', () {
    final full = Board.parse('1234\n3412\n2143\n4321');

    expect(full.isFull, isTrue);
    expect(full.filledCellCount, 16);
    expect(full.withCell(0, 0, Board.emptyValue).isFull, isFalse);
  });

  test('row and column return the digits in order', () {
    final board = Board.parse('1234\n3412\n2143\n4321');

    expect(board.row(1), [3, 4, 1, 2]);
    expect(board.column(2), [3, 1, 4, 2]);
  });
}
