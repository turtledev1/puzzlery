import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../l10n/localized_labels.dart';
import '../puzzles/puzzle_definition.dart';
import 'settings_screen.dart';

class PuzzleSettingsScreen extends StatelessWidget {
  const PuzzleSettingsScreen({super.key, required this.definition});

  final PuzzleDefinition definition;

  @override
  Widget build(BuildContext context) {
    final settingsController = AppScope.of(context).settingsController;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.puzzleSettingsTitle(strings.puzzleName(definition.kind)),
        ),
      ),
      body: ListenableBuilder(
        listenable: settingsController,
        builder: (context, _) => ListView(
          children: [
            ...definition.buildPuzzleSettings(strings, settingsController),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(strings.allSettings),
              subtitle: Text(strings.allSettingsDescription),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
