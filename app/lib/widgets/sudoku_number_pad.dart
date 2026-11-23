import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/sudoku_game_controller.dart';
import '../l10n/localized_labels.dart';

class SudokuNumberPad extends StatelessWidget {
  const SudokuNumberPad({
    super.key,
    required this.controller,
    this.tapFeedbackEnabled = false,
  });

  static const double buttonHeight = 56;

  final SudokuGameController controller;
  final bool tapFeedbackEnabled;

  void _buzzWhenCellChanged(bool cellChanged) {
    if (cellChanged && tapFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final textTheme = Theme.of(context).textTheme;
    final canEditSelectedCell = controller.canEditSelectedCell;
    final toggleNotesMode = controller.isSolved
        ? null
        : controller.toggleNotesMode;
    const notesIcon = Icon(Icons.edit_note);
    final notesLabel = Text(strings.sudokuNotes);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: controller.isNotesMode
                  ? FilledButton.icon(
                      key: const ValueKey('notes-button'),
                      onPressed: toggleNotesMode,
                      icon: notesIcon,
                      label: notesLabel,
                    )
                  : OutlinedButton.icon(
                      key: const ValueKey('notes-button'),
                      onPressed: toggleNotesMode,
                      icon: notesIcon,
                      label: notesLabel,
                    ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('erase-button'),
                onPressed: canEditSelectedCell
                    ? () => _buzzWhenCellChanged(controller.eraseSelectedCell())
                    : null,
                icon: const Icon(Icons.backspace_outlined),
                label: Text(strings.sudokuErase),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            for (var digit = 1; digit <= controller.size; digit++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: FilledButton.tonal(
                    key: ValueKey('digit-button-$digit'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, buttonHeight),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: canEditSelectedCell
                        ? () =>
                              _buzzWhenCellChanged(controller.enterDigit(digit))
                        : null,
                    child: Text('$digit', style: textTheme.headlineSmall),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
