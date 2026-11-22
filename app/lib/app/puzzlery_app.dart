import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../screens/home_screen.dart';
import 'app_services.dart';

class PuzzleryApp extends StatelessWidget {
  const PuzzleryApp({super.key, required this.services});

  static const Color brandColor = Color(0xFF3D7DD8);

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: ListenableBuilder(
        listenable: services.settingsController,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: services.settingsController.settings.language.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          themeMode: services.settingsController.settings.themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: brandColor),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: brandColor,
              brightness: Brightness.dark,
            ),
          ),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
