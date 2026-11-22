import 'package:flutter/material.dart';

import 'app/app_services.dart';
import 'app/puzzlery_app.dart';
import 'game/saved_game_repository.dart';
import 'settings/settings_controller.dart';
import 'statistics/statistics_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settingsController = await SettingsController.load();
  runApp(
    PuzzleryApp(
      services: AppServices(
        savedGameRepository: SavedGameRepository(),
        statisticsRepository: StatisticsRepository(),
        settingsController: settingsController,
      ),
    ),
  );
}
