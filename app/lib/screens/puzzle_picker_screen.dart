import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../game/game_controller.dart';
import '../game/saved_game_repository.dart';
import '../l10n/localized_labels.dart';
import '../puzzles/puzzle_kind.dart';
import '../widgets/app_logo.dart';
import '../widgets/continue_card.dart';
import 'binairo_home_screen.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'statistics_screen.dart';

class PuzzlePickerScreen extends StatefulWidget {
  const PuzzlePickerScreen({super.key});

  @override
  State<PuzzlePickerScreen> createState() => _PuzzlePickerScreenState();
}

class _PuzzlePickerScreenState extends State<PuzzlePickerScreen> {
  late AppServices _services;
  SavedGame? _savedGame;
  bool _hasLoadedOnce = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _services = AppScope.of(context);
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
      _loadSavedGame();
    }
  }

  Future<void> _loadSavedGame() async {
    final savedGame = await _services.savedGameRepository.load();
    if (mounted) {
      setState(() => _savedGame = savedGame);
    }
  }

  Future<void> _openScreenThenRefresh(Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
    await _loadSavedGame();
  }

  Widget _homeScreenOf(PuzzleKind puzzleKind) => switch (puzzleKind) {
    PuzzleKind.binairo => const BinairoHomeScreen(),
  };

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final savedGame = _savedGame;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appTitle,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: strings.statistics,
            icon: const Icon(Icons.bar_chart),
            onPressed: () => _openScreenThenRefresh(const StatisticsScreen()),
          ),
          IconButton(
            tooltip: strings.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _openScreenThenRefresh(const SettingsScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (savedGame != null) ...[
                  ContinueCard(
                    savedGame: savedGame,
                    puzzleName: strings.puzzleName(PuzzleKind.binairo),
                    onTap: () => _openScreenThenRefresh(
                      GameScreen(controller: GameController.resume(savedGame)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                for (final puzzleKind in PuzzleKind.values) ...[
                  _PuzzleCard(
                    puzzleKind: puzzleKind,
                    onTap: () =>
                        _openScreenThenRefresh(_homeScreenOf(puzzleKind)),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PuzzleCard extends StatelessWidget {
  const _PuzzleCard({required this.puzzleKind, required this.onTap});

  final PuzzleKind puzzleKind;
  final VoidCallback onTap;

  Widget get _logo => switch (puzzleKind) {
    PuzzleKind.binairo => const AppLogo(size: 64),
  };

  @override
  Widget build(BuildContext context) {
    final puzzleColors = ColorScheme.fromSeed(
      seedColor: puzzleKind.seedColor,
      brightness: Theme.of(context).brightness,
    );
    final textTheme = Theme.of(context).textTheme;
    final strings = context.strings;
    return Card.filled(
      key: ValueKey('puzzle-card-${puzzleKind.name}'),
      color: puzzleColors.primaryContainer,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _logo,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.puzzleName(puzzleKind),
                      style: textTheme.titleLarge?.copyWith(
                        color: puzzleColors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.puzzleTagline(puzzleKind),
                      style: textTheme.bodyMedium?.copyWith(
                        color: puzzleColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: puzzleColors.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
