import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../l10n/localized_labels.dart';
import '../puzzles/puzzle_kind.dart';
import 'settings_screen.dart';

class BinairoSettingsScreen extends StatelessWidget {
  const BinairoSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = AppScope.of(context).settingsController;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.puzzleSettingsTitle(strings.puzzleName(PuzzleKind.binairo)),
        ),
      ),
      body: ListenableBuilder(
        listenable: settingsController,
        builder: (context, _) {
          final settings = settingsController.settings;
          return ListView(
            children: [
              SwitchListTile(
                title: Text(strings.showRuleErrors),
                subtitle: Text(strings.showRuleErrorsDescription),
                value: settings.showRuleErrors,
                onChanged: (enabled) => settingsController.update(
                  (current) => current.copyWith(showRuleErrors: enabled),
                ),
              ),
              SwitchListTile(
                title: Text(strings.showLineCounters),
                subtitle: Text(strings.showLineCountersDescription),
                value: settings.showLineCounters,
                onChanged: (enabled) => settingsController.update(
                  (current) => current.copyWith(showLineCounters: enabled),
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: Text(strings.allSettings),
                subtitle: Text(strings.allSettingsDescription),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
