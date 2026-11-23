import 'package:flutter/foundation.dart';
import 'package:sudoku_core/sudoku_core.dart';

/// A cell's notes are a bit mask: digit d is noted when bit `1 << d` is set.
@immutable
class SudokuGameState {
  SudokuGameState({required this.board, required List<int> noteMasks})
    : noteMasks = List.unmodifiable(noteMasks) {
    if (noteMasks.length != board.size * board.size) {
      throw ArgumentError.value(
        noteMasks.length,
        'noteMasks',
        'Needs one mask per cell (${board.size * board.size}).',
      );
    }
  }

  factory SudokuGameState.withoutNotes(Board board) => SudokuGameState(
    board: board,
    noteMasks: List.filled(board.size * board.size, 0),
  );

  final Board board;
  final List<int> noteMasks;

  int get size => board.size;

  List<int> notedDigitsAt(int row, int column) {
    final noteMask = noteMasks[row * size + column];
    return [
      for (var digit = 1; digit <= size; digit++)
        if (noteMask & (1 << digit) != 0) digit,
    ];
  }

  bool hasNotesAt(int row, int column) => noteMasks[row * size + column] != 0;

  SudokuGameState withDigit(int row, int column, int digit) => SudokuGameState(
    board: board.withCell(row, column, digit),
    noteMasks: _noteMasksWith(row, column, 0),
  );

  SudokuGameState withNoteToggled(int row, int column, int digit) =>
      SudokuGameState(
        board: board,
        noteMasks: _noteMasksWith(
          row,
          column,
          noteMasks[row * size + column] ^ (1 << digit),
        ),
      );

  SudokuGameState withCellCleared(int row, int column) =>
      withDigit(row, column, Board.emptyValue);

  List<int> _noteMasksWith(int row, int column, int noteMask) =>
      List.of(noteMasks)..[row * size + column] = noteMask;

  @override
  bool operator ==(Object other) =>
      other is SudokuGameState &&
      other.board == board &&
      listEquals(other.noteMasks, noteMasks);

  @override
  int get hashCode => Object.hash(board, Object.hashAll(noteMasks));
}
