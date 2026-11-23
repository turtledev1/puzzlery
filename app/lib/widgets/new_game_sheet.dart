import 'package:flutter/material.dart';

import '../l10n/localized_labels.dart';

typedef NewGameChoice<DifficultyType extends Enum> = ({
  int size,
  DifficultyType difficulty,
});

Future<NewGameChoice<DifficultyType>?>
showNewGameSheet<DifficultyType extends Enum>(
  BuildContext context, {
  required List<int> boardSizes,
  required List<DifficultyType> difficulties,
  required int initialSize,
  required DifficultyType initialDifficulty,
  required String Function(DifficultyType difficulty) difficultyName,
  required String Function(DifficultyType difficulty) difficultyDescription,
}) => showModalBottomSheet<NewGameChoice<DifficultyType>>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _NewGameSheet(
    boardSizes: boardSizes,
    difficulties: difficulties,
    initialSize: initialSize,
    initialDifficulty: initialDifficulty,
    difficultyName: difficultyName,
    difficultyDescription: difficultyDescription,
  ),
);

class _NewGameSheet<DifficultyType extends Enum> extends StatefulWidget {
  const _NewGameSheet({
    required this.boardSizes,
    required this.difficulties,
    required this.initialSize,
    required this.initialDifficulty,
    required this.difficultyName,
    required this.difficultyDescription,
  });

  final List<int> boardSizes;
  final List<DifficultyType> difficulties;
  final int initialSize;
  final DifficultyType initialDifficulty;
  final String Function(DifficultyType difficulty) difficultyName;
  final String Function(DifficultyType difficulty) difficultyDescription;

  @override
  State<_NewGameSheet<DifficultyType>> createState() =>
      _NewGameSheetState<DifficultyType>();
}

class _NewGameSheetState<DifficultyType extends Enum>
    extends State<_NewGameSheet<DifficultyType>> {
  late int _selectedSize = widget.initialSize;
  late DifficultyType _selectedDifficulty = widget.initialDifficulty;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final strings = context.strings;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(strings.newGame, style: textTheme.headlineSmall),
            const SizedBox(height: 24),
            Text(strings.boardSize, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                for (final size in widget.boardSizes)
                  ButtonSegment(value: size, label: Text('$size×$size')),
              ],
              selected: {_selectedSize},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _selectedSize = selection.single),
            ),
            const SizedBox(height: 24),
            Text(strings.difficultyLevel, style: textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<DifficultyType>(
              segments: [
                for (final difficulty in widget.difficulties)
                  ButtonSegment(
                    value: difficulty,
                    label: Text(widget.difficultyName(difficulty)),
                  ),
              ],
              selected: {_selectedDifficulty},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _selectedDifficulty = selection.single),
            ),
            const SizedBox(height: 8),
            Text(
              widget.difficultyDescription(_selectedDifficulty),
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
              onPressed: () => Navigator.of(
                context,
              ).pop((size: _selectedSize, difficulty: _selectedDifficulty)),
              child: Text(strings.start),
            ),
          ],
        ),
      ),
    );
  }
}
