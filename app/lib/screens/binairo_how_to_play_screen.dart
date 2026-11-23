import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

import '../l10n/localized_labels.dart';
import '../widgets/binairo_board_cell.dart';
import '../widgets/how_to_play_parts.dart';

class BinairoHowToPlayScreen extends StatelessWidget {
  const BinairoHowToPlayScreen({super.key});

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
          Text(strings.howToPlayIntro, style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          _RuleCard(
            number: 1,
            title: strings.ruleNoThreeInARowTitle,
            explanation: strings.ruleNoThreeInARowExplanation,
            goodLine: '001101',
            badLine: '000111',
            badCells: {0, 1, 2, 3, 4, 5},
          ),
          _RuleCard(
            number: 2,
            title: strings.ruleBalancedLinesTitle,
            explanation: strings.ruleBalancedLinesExplanation,
            goodLine: '010011',
            badLine: '011011',
            badCells: {1, 2, 4, 5},
          ),
          _RuleCard(
            number: 3,
            title: strings.ruleUniqueLinesTitle,
            explanation: strings.ruleUniqueLinesExplanation,
            goodLine: '010011',
            secondGoodLine: '011001',
            badLine: '010011',
            secondBadLine: '010011',
            badCells: {0, 1, 2, 3, 4, 5},
          ),
          const SizedBox(height: 8),
          Text(strings.controlsTitle, style: textTheme.titleLarge),
          const SizedBox(height: 8),
          HowToPlayControlTip(
            icon: Icons.touch_app_outlined,
            text: strings.controlTapCell,
          ),
          HowToPlayControlTip(
            icon: Icons.lock_outline,
            text: strings.controlClues,
          ),
          HowToPlayControlTip(
            icon: Icons.error_outline,
            text: strings.controlRuleErrors,
          ),
          HowToPlayControlTip(
            icon: Icons.format_list_numbered,
            text: strings.controlLineCounters,
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

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.number,
    required this.title,
    required this.explanation,
    required this.goodLine,
    required this.badLine,
    required this.badCells,
    this.secondGoodLine,
    this.secondBadLine,
  });

  final int number;
  final String title;
  final String explanation;
  final String goodLine;
  final String? secondGoodLine;
  final String badLine;
  final String? secondBadLine;
  final Set<int> badCells;

  @override
  Widget build(BuildContext context) {
    final secondGoodLine = this.secondGoodLine;
    final secondBadLine = this.secondBadLine;
    return HowToPlayRuleCard(
      number: number,
      title: title,
      explanation: explanation,
      examples: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HowToPlayExampleLabel(isGood: true),
          _ExampleLine(digits: goodLine),
          if (secondGoodLine != null) _ExampleLine(digits: secondGoodLine),
          const SizedBox(height: 12),
          const HowToPlayExampleLabel(isGood: false),
          _ExampleLine(digits: badLine, cellsInViolation: badCells),
          if (secondBadLine != null)
            _ExampleLine(digits: secondBadLine, cellsInViolation: badCells),
        ],
      ),
    );
  }
}

class _ExampleLine extends StatelessWidget {
  const _ExampleLine({required this.digits, this.cellsInViolation = const {}});

  static const double cellSize = 40;

  final String digits;
  final Set<int> cellsInViolation;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var position = 0; position < digits.length; position++)
          SizedBox.square(
            dimension: cellSize,
            child: BinairoBoardCell(
              value: digits[position] == '0' ? CellValue.zero : CellValue.one,
              isGiven: false,
              isInViolation: cellsInViolation.contains(position),
              onTap: () {},
            ),
          ),
      ],
    );
  }
}
