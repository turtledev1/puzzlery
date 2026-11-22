import 'cell_position.dart';

class Board {
  Board._(this.size, List<int> cells)
    : boxHeight = _boxHeightBySize[size]!,
      boxWidth = size ~/ _boxHeightBySize[size]!,
      _cells = List.unmodifiable(cells);

  factory Board.empty(int size) {
    _throwIfSizeIsUnsupported(size);
    return Board._(size, List.filled(size * size, emptyValue));
  }

  factory Board.fromCells(int size, List<int> cells) {
    _throwIfSizeIsUnsupported(size);
    if (cells.length != size * size) {
      throw ArgumentError(
        'A board of size $size needs ${size * size} cells, got ${cells.length}.',
      );
    }
    for (final value in cells) {
      _throwIfValueIsOutOfRange(size, value);
    }
    return Board._(size, cells);
  }

  /// One row per line; cells are digits, with `.` or `0` for empty.
  factory Board.parse(String text) {
    final rows = text
        .split('\n')
        .map((row) => row.trim())
        .where((row) => row.isNotEmpty)
        .toList();
    final size = rows.length;
    final cells = <int>[];
    for (final row in rows) {
      if (row.length != size) {
        throw FormatException('Every row must have $size cells.', row);
      }
      for (final character in row.split('')) {
        if (character == '.') {
          cells.add(emptyValue);
          continue;
        }
        final digit = int.tryParse(character);
        if (digit == null) {
          throw FormatException('Unknown cell character.', character);
        }
        cells.add(digit);
      }
    }
    return Board.fromCells(size, cells);
  }

  static const int emptyValue = 0;

  static const Map<int, int> _boxHeightBySize = {4: 2, 6: 2, 9: 3};

  static Iterable<int> get supportedSizes => _boxHeightBySize.keys;

  final int size;
  final int boxHeight;
  final int boxWidth;
  final List<int> _cells;

  List<int> get cells => _cells;

  int cellAt(int row, int column) => _cells[row * size + column];

  int cellAtPosition(CellPosition position) =>
      cellAt(position.row, position.column);

  bool isEmptyAt(int row, int column) => cellAt(row, column) == emptyValue;

  int boxIndexOf(int row, int column) =>
      (row ~/ boxHeight) * (size ~/ boxWidth) + column ~/ boxWidth;

  Board withCell(int row, int column, int value) {
    _throwIfValueIsOutOfRange(size, value);
    final updatedCells = List.of(_cells);
    updatedCells[row * size + column] = value;
    return Board._(size, updatedCells);
  }

  List<int> row(int rowIndex) =>
      _cells.sublist(rowIndex * size, rowIndex * size + size);

  List<int> column(int columnIndex) => [
    for (var rowIndex = 0; rowIndex < size; rowIndex++)
      cellAt(rowIndex, columnIndex),
  ];

  bool get isFull => !_cells.contains(emptyValue);

  int get filledCellCount =>
      _cells.where((value) => value != emptyValue).length;

  String toText() {
    final buffer = StringBuffer();
    for (var rowIndex = 0; rowIndex < size; rowIndex++) {
      for (final value in row(rowIndex)) {
        buffer.write(value == emptyValue ? '.' : '$value');
      }
      if (rowIndex < size - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is Board &&
      other.size == size &&
      _cellsAreEqual(other._cells, _cells);

  @override
  int get hashCode => Object.hash(size, Object.hashAll(_cells));

  @override
  String toString() => toText();

  static bool _cellsAreEqual(List<int> first, List<int> second) {
    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) {
        return false;
      }
    }
    return true;
  }

  static void _throwIfSizeIsUnsupported(int size) {
    if (!_boxHeightBySize.containsKey(size)) {
      throw ArgumentError.value(
        size,
        'size',
        'Must be one of ${supportedSizes.join(', ')}.',
      );
    }
  }

  static void _throwIfValueIsOutOfRange(int size, int value) {
    if (value < emptyValue || value > size) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be between 1 and $size, or $emptyValue for empty.',
      );
    }
  }
}
