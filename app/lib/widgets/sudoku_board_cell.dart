import 'package:flutter/material.dart';
import 'package:sudoku_core/sudoku_core.dart';

import 'puzzle_colors.dart';

enum SudokuCellHighlight { none, peerOfSelected, sameDigitAsSelected, selected }

class SudokuBoardCell extends StatelessWidget {
  const SudokuBoardCell({
    super.key,
    required this.digit,
    required this.isGiven,
    required this.isInViolation,
    this.notedDigits = const [],
    this.noteRowCount = 3,
    this.noteColumnCount = 3,
    this.highlight = SudokuCellHighlight.none,
    this.onTap,
  });

  final int digit;
  final bool isGiven;
  final bool isInViolation;
  final List<int> notedDigits;

  /// The notes grid has the shape of a box.
  final int noteRowCount;
  final int noteColumnCount;
  final SudokuCellHighlight highlight;
  final VoidCallback? onTap;

  static const Color _playerDigitColorOnDark = Color(0xFF5DA9FF);
  static const Color _playerDigitColorOnLight = Color(0xFF1A5FD0);

  static Color playerDigitColorFor(Brightness brightness) =>
      brightness == Brightness.dark
      ? _playerDigitColorOnDark
      : _playerDigitColorOnLight;

  Color _backgroundColor(ColorScheme colorScheme) {
    final baseColor = isGiven
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surfaceContainerLowest;
    final highlightColor = switch (highlight) {
      SudokuCellHighlight.none => null,
      SudokuCellHighlight.peerOfSelected => colorScheme.onSurface.withValues(
        alpha: 0.08,
      ),
      SudokuCellHighlight.sameDigitAsSelected => colorScheme.primary.withValues(
        alpha: 0.22,
      ),
      SudokuCellHighlight.selected => colorScheme.primary.withValues(
        alpha: 0.4,
      ),
    };
    return highlightColor == null
        ? baseColor
        : Color.alphaBlend(highlightColor, baseColor);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ColoredBox(
        color: _backgroundColor(colorScheme),
        child: Container(
          margin: EdgeInsets.all(isInViolation ? 2 : 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: isInViolation
                ? Border.all(
                    color: PuzzleColors.ruleViolation,
                    width: PuzzleColors.ruleViolationRingWidth,
                  )
                : null,
          ),
          alignment: Alignment.center,
          child: digit == Board.emptyValue
              ? _buildNotes(colorScheme)
              : _buildDigit(colorScheme),
        ),
      ),
    );
  }

  Widget _buildDigit(ColorScheme colorScheme) => FittedBox(
    child: Padding(
      padding: const EdgeInsets.all(4),
      child: Text(
        '$digit',
        style: TextStyle(
          color: isGiven
              ? colorScheme.onSurface
              : playerDigitColorFor(colorScheme.brightness),
          fontWeight: isGiven ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    ),
  );

  Widget? _buildNotes(ColorScheme colorScheme) {
    if (notedDigits.isEmpty) {
      return null;
    }
    return Padding(
      padding: const EdgeInsets.all(1),
      child: Column(
        children: [
          for (var noteRow = 0; noteRow < noteRowCount; noteRow++)
            Expanded(
              child: Row(
                children: [
                  for (
                    var noteColumn = 0;
                    noteColumn < noteColumnCount;
                    noteColumn++
                  )
                    Expanded(
                      child: _buildNote(
                        noteRow * noteColumnCount + noteColumn + 1,
                        colorScheme,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNote(int noteDigit, ColorScheme colorScheme) {
    if (!notedDigits.contains(noteDigit)) {
      return const SizedBox.shrink();
    }
    return FittedBox(
      child: Text(
        '$noteDigit',
        style: TextStyle(
          color: playerDigitColorFor(colorScheme.brightness),
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
