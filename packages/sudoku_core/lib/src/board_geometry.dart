import 'board.dart';

class BoardGeometry {
  BoardGeometry._(this.size) {
    final emptyBoard = Board.empty(size);
    rowOfCell = [for (var cell = 0; cell < cellCount; cell++) cell ~/ size];
    columnOfCell = [for (var cell = 0; cell < cellCount; cell++) cell % size];
    boxOfCell = [
      for (var cell = 0; cell < cellCount; cell++)
        emptyBoard.boxIndexOf(cell ~/ size, cell % size),
    ];
    rows = [
      for (var row = 0; row < size; row++)
        [for (var column = 0; column < size; column++) row * size + column],
    ];
    columns = [
      for (var column = 0; column < size; column++)
        [for (var row = 0; row < size; row++) row * size + column],
    ];
    boxes = [
      for (var box = 0; box < size; box++)
        [
          for (var cell = 0; cell < cellCount; cell++)
            if (boxOfCell[cell] == box) cell,
        ],
    ];
    units = [...rows, ...columns, ...boxes];
    peersOfCell = [
      for (var cell = 0; cell < cellCount; cell++)
        {
          ...rows[rowOfCell[cell]],
          ...columns[columnOfCell[cell]],
          ...boxes[boxOfCell[cell]],
        }.where((peer) => peer != cell).toList(),
    ];
  }

  factory BoardGeometry.forSize(int size) =>
      _geometryBySize.putIfAbsent(size, () => BoardGeometry._(size));

  static final Map<int, BoardGeometry> _geometryBySize = {};

  final int size;
  late final List<int> rowOfCell;
  late final List<int> columnOfCell;
  late final List<int> boxOfCell;
  late final List<List<int>> rows;
  late final List<List<int>> columns;
  late final List<List<int>> boxes;

  /// Rows, then columns, then boxes.
  late final List<List<int>> units;
  late final List<List<int>> peersOfCell;

  int get cellCount => size * size;
}
