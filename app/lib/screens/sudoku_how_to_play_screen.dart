import 'package:flutter/material.dart';

import '../l10n/localized_labels.dart';
import '../widgets/how_to_play_parts.dart';
import '../widgets/sudoku_board_cell.dart';

class SudokuHowToPlayScreen extends StatelessWidget {
  const SudokuHowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(title: Text(strings.howToPlay)),
      body: ListView(
        padding:
            const EdgeInsets.all(16) +
            EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        children: [
          Text(strings.sudokuHowToPlayIntro, style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          HowToPlayRuleCard(
            number: 1,
            title: strings.sudokuRuleRowTitle,
            explanation: strings.sudokuRuleRowExplanation,
            examples: const _GoodAndBadExamples(
              goodRows: ['1234'],
              badRows: ['1231'],
              badCellIndexesRowByRow: {0, 3},
            ),
          ),
          HowToPlayRuleCard(
            number: 2,
            title: strings.sudokuRuleColumnTitle,
            explanation: strings.sudokuRuleColumnExplanation,
            examples: const _GoodAndBadExamples(
              goodRows: ['1', '2', '3', '4'],
              badRows: ['2', '1', '2', '4'],
              badCellIndexesRowByRow: {0, 2},
            ),
          ),
          HowToPlayRuleCard(
            number: 3,
            title: strings.sudokuRuleBoxTitle,
            explanation: strings.sudokuRuleBoxExplanation,
            examples: const _GoodAndBadExamples(
              goodRows: ['12', '34'],
              badRows: ['12', '31'],
              badCellIndexesRowByRow: {0, 3},
            ),
          ),
          const SizedBox(height: 8),
          Text(strings.controlsTitle, style: textTheme.titleLarge),
          const SizedBox(height: 8),
          HowToPlayControlTip(
            icon: Icons.touch_app_outlined,
            text: strings.sudokuControlEnterDigit,
          ),
          HowToPlayControlTip(
            icon: Icons.edit_note,
            text: strings.sudokuControlNotes,
          ),
          HowToPlayControlTip(
            icon: Icons.backspace_outlined,
            text: strings.sudokuControlErase,
          ),
          HowToPlayControlTip(
            icon: Icons.lock_outline,
            text: strings.sudokuControlClues,
          ),
          HowToPlayControlTip(
            icon: Icons.error_outline,
            text: strings.controlRuleErrors,
          ),
          HowToPlayControlTip(
            icon: Icons.lightbulb_outline,
            text: strings.controlHint,
          ),
          HowToPlayControlTip(icon: Icons.undo, text: strings.controlUndo),
        ],
      ),
    );
  }
}

class _GoodAndBadExamples extends StatelessWidget {
  const _GoodAndBadExamples({
    required this.goodRows,
    required this.badRows,
    required this.badCellIndexesRowByRow,
  });

  final List<String> goodRows;
  final List<String> badRows;
  final Set<int> badCellIndexesRowByRow;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 32,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HowToPlayExampleLabel(isGood: true),
            _ExampleGrid(rows: goodRows),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HowToPlayExampleLabel(isGood: false),
            _ExampleGrid(
              rows: badRows,
              badCellIndexesRowByRow: badCellIndexesRowByRow,
            ),
          ],
        ),
      ],
    );
  }
}

class _ExampleGrid extends StatelessWidget {
  const _ExampleGrid({
    required this.rows,
    this.badCellIndexesRowByRow = const {},
  });

  static const double cellSize = 36;

  final List<String> rows;
  final Set<int> badCellIndexesRowByRow;

  @override
  Widget build(BuildContext context) {
    final lineColor = Theme.of(context).colorScheme.onSurfaceVariant;
    final columnCount = rows.first.length;
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(border: Border.all(color: lineColor, width: 2)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var row = 0; row < rows.length; row++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var column = 0; column < columnCount; column++)
                  DecoratedBox(
                    position: DecorationPosition.foreground,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: lineColor.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: SizedBox.square(
                      dimension: cellSize,
                      child: SudokuBoardCell(
                        digit: int.parse(rows[row][column]),
                        isGiven: false,
                        isInViolation: badCellIndexesRowByRow.contains(
                          row * columnCount + column,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
