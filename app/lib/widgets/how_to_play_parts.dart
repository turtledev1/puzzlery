import 'package:flutter/material.dart';

import '../l10n/localized_labels.dart';
import 'puzzle_colors.dart';

class HowToPlayRuleCard extends StatelessWidget {
  const HowToPlayRuleCard({
    super.key,
    required this.number,
    required this.title,
    required this.explanation,
    required this.examples,
  });

  final int number;
  final String title;
  final String explanation;
  final Widget examples;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.strings.ruleCardTitle(number, title),
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(explanation, style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            examples,
          ],
        ),
      ),
    );
  }
}

class HowToPlayExampleLabel extends StatelessWidget {
  const HowToPlayExampleLabel({super.key, required this.isGood});

  final bool isGood;

  @override
  Widget build(BuildContext context) {
    final color = isGood ? Colors.green : PuzzleColors.ruleViolation;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGood ? Icons.check_circle : Icons.cancel,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            isGood
                ? context.strings.exampleCorrect
                : context.strings.exampleWrong,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class HowToPlayControlTip extends StatelessWidget {
  const HowToPlayControlTip({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(text),
    );
  }
}
