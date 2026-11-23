import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sudoku_core/sudoku_core.dart';

import '../game/sudoku_game_controller.dart';
import 'celebration.dart';
import 'hint_pulse.dart';
import 'puzzle_colors.dart';
import 'sudoku_board_cell.dart';

class SudokuBoardGrid extends StatelessWidget {
  const SudokuBoardGrid({
    super.key,
    required this.controller,
    this.celebration = kAlwaysDismissedAnimation,
    this.showRuleErrors = true,
  });

  final SudokuGameController controller;
  final Animation<double> celebration;
  final bool showRuleErrors;

  SudokuCellHighlight _highlightOf(int row, int column) {
    final selectedCell = controller.selectedCell;
    if (selectedCell == null) {
      return SudokuCellHighlight.none;
    }
    if (selectedCell == CellPosition(row, column)) {
      return SudokuCellHighlight.selected;
    }
    final board = controller.currentBoard;
    final selectedDigit = board.cellAtPosition(selectedCell);
    if (selectedDigit != Board.emptyValue &&
        board.cellAt(row, column) == selectedDigit) {
      return SudokuCellHighlight.sameDigitAsSelected;
    }
    final sharesRowColumnOrBox =
        selectedCell.row == row ||
        selectedCell.column == column ||
        board.boxIndexOf(selectedCell.row, selectedCell.column) ==
            board.boxIndexOf(row, column);
    return sharesRowColumnOrBox
        ? SudokuCellHighlight.peerOfSelected
        : SudokuCellHighlight.none;
  }

  Widget _withHintPulse(int row, int column, Widget cell) {
    final hint = controller.activeHint;
    if (hint == null || hint.cell != CellPosition(row, column)) {
      return cell;
    }
    return HintPulse(
      key: ValueKey('hint-$row-$column'),
      color: switch (hint) {
        DeducibleCellHint() => HintPulse.deducibleCellColor,
        WrongCellHint() => PuzzleColors.ruleViolation,
      },
      child: cell,
    );
  }

  @override
  Widget build(BuildContext context) {
    final board = controller.currentBoard;
    final size = board.size;
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize =
            min(constraints.maxWidth, constraints.maxHeight) / size;
        return SizedBox.square(
          dimension: cellSize * size,
          child: Stack(
            children: [
              Column(
                children: [
                  for (var row = 0; row < size; row++)
                    SizedBox(
                      height: cellSize,
                      child: Row(
                        children: [
                          for (var column = 0; column < size; column++)
                            SizedBox.square(
                              dimension: cellSize,
                              child: _withHintPulse(
                                row,
                                column,
                                CelebrationWave(
                                  celebration: celebration,
                                  row: row,
                                  column: column,
                                  boardSize: size,
                                  child: SudokuBoardCell(
                                    key: ValueKey('cell-$row-$column'),
                                    digit: board.cellAt(row, column),
                                    isGiven: controller.isGivenCell(
                                      row,
                                      column,
                                    ),
                                    isInViolation:
                                        showRuleErrors &&
                                        controller.cellsInViolation.contains(
                                          CellPosition(row, column),
                                        ),
                                    notedDigits: controller.currentState
                                        .notedDigitsAt(row, column),
                                    noteRowCount: board.boxHeight,
                                    noteColumnCount: board.boxWidth,
                                    highlight: _highlightOf(row, column),
                                    onTap: () =>
                                        controller.selectCell(row, column),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _GridLinesPainter(
                      size: size,
                      boxHeight: board.boxHeight,
                      boxWidth: board.boxWidth,
                      thinLineColor: colorScheme.outlineVariant,
                      thickLineColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GridLinesPainter extends CustomPainter {
  _GridLinesPainter({
    required this.size,
    required this.boxHeight,
    required this.boxWidth,
    required this.thinLineColor,
    required this.thickLineColor,
  });

  static const double thinLineWidth = 1;
  static const double thickLineWidth = 2.5;

  final int size;
  final int boxHeight;
  final int boxWidth;
  final Color thinLineColor;
  final Color thickLineColor;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final cellSize = canvasSize.width / size;
    final thinPaint = Paint()
      ..color = thinLineColor
      ..strokeWidth = thinLineWidth;
    final thickPaint = Paint()
      ..color = thickLineColor
      ..strokeWidth = thickLineWidth;
    void drawVerticalLine(int lineIndex, Paint paint) => canvas.drawLine(
      Offset(lineIndex * cellSize, 0),
      Offset(lineIndex * cellSize, canvasSize.height),
      paint,
    );
    void drawHorizontalLine(int lineIndex, Paint paint) => canvas.drawLine(
      Offset(0, lineIndex * cellSize),
      Offset(canvasSize.width, lineIndex * cellSize),
      paint,
    );

    for (var lineIndex = 0; lineIndex <= size; lineIndex++) {
      drawVerticalLine(lineIndex, thinPaint);
      drawHorizontalLine(lineIndex, thinPaint);
    }
    for (var lineIndex = 0; lineIndex <= size; lineIndex += boxWidth) {
      drawVerticalLine(lineIndex, thickPaint);
    }
    for (var lineIndex = 0; lineIndex <= size; lineIndex += boxHeight) {
      drawHorizontalLine(lineIndex, thickPaint);
    }
  }

  @override
  bool shouldRepaint(_GridLinesPainter oldDelegate) =>
      oldDelegate.size != size ||
      oldDelegate.boxHeight != boxHeight ||
      oldDelegate.boxWidth != boxWidth ||
      oldDelegate.thinLineColor != thinLineColor ||
      oldDelegate.thickLineColor != thickLineColor;
}
