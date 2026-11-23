import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../l10n/app_localizations.dart';
import '../l10n/localized_labels.dart';
import '../settings/app_settings.dart';
import '../widgets/app_logo.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = AppScope.of(context).settingsController;
    final textTheme = Theme.of(context).textTheme;
    final strings = context.strings;
    Widget sectionTitle(String title) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(strings.settings)),
      body: ListenableBuilder(
        listenable: settingsController,
        builder: (context, _) {
          final settings = settingsController.settings;
          return ListView(
            children: [
              sectionTitle(strings.settingsAppearance),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(strings.followPhone),
                      icon: const Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(strings.themeLight),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(strings.themeDark),
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {settings.themeMode},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) => settingsController.update(
                    (current) => current.copyWith(themeMode: selection.single),
                  ),
                ),
              ),
              sectionTitle(strings.settingsGame),
              SwitchListTile(
                title: Text(strings.vibration),
                subtitle: Text(strings.vibrationDescription),
                value: settings.vibrationEnabled,
                onChanged: (enabled) => settingsController.update(
                  (current) => current.copyWith(vibrationEnabled: enabled),
                ),
              ),
              SwitchListTile(
                title: Text(strings.autoHint),
                subtitle: Text(strings.autoHintDescription),
                value: settings.autoHintEnabled,
                onChanged: (enabled) => settingsController.update(
                  (current) => current.copyWith(autoHintEnabled: enabled),
                ),
              ),
              if (settings.autoHintEnabled)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SegmentedButton<Duration>(
                    segments: [
                      for (final delay in AppSettings.autoHintDelayChoices)
                        ButtonSegment(
                          value: delay,
                          label: Text(_describeDelay(strings, delay)),
                        ),
                    ],
                    selected: {settings.autoHintDelay},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        settingsController.update(
                          (current) =>
                              current.copyWith(autoHintDelay: selection.single),
                        ),
                  ),
                ),
              sectionTitle(strings.settingsLanguage),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownMenu<AppLanguage>(
                  key: const ValueKey('language-dropdown'),
                  expandedInsets: EdgeInsets.zero,
                  leadingIcon: const Icon(Icons.language),
                  initialSelection: settings.language,
                  dropdownMenuEntries: [
                    for (final language in AppLanguage.values)
                      DropdownMenuEntry(
                        value: language,
                        label: _languageLabel(strings, language),
                      ),
                  ],
                  onSelected: (language) {
                    if (language == null) return;
                    settingsController.update(
                      (current) => current.copyWith(language: language),
                    );
                  },
                ),
              ),
              sectionTitle(strings.settingsAbout),
              AboutListTile(
                icon: const Icon(Icons.info_outline),
                applicationName: strings.appTitle,
                applicationIcon: const AppLogo(size: 48),
              ),
            ],
          );
        },
      ),
    );
  }
}

String _describeDelay(AppLocalizations strings, Duration delay) =>
    delay.inSeconds < 60
    ? strings.delayInSeconds(delay.inSeconds)
    : strings.delayInMinutes(delay.inMinutes);

String _languageLabel(AppLocalizations strings, AppLanguage language) =>
    switch (language) {
      AppLanguage.phone => strings.followPhone,
      AppLanguage.english => strings.languageNameEnglish,
      AppLanguage.french => strings.languageNameFrench,
    };
