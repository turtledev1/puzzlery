import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../game/saved_game_repository.dart';
import '../l10n/localized_labels.dart';
import '../puzzles/puzzle_definition.dart';
import '../puzzles/puzzle_kind.dart';
import '../widgets/continue_card.dart';
import 'puzzle_home_screen.dart';
import 'settings_screen.dart';

class PuzzlePickerScreen extends StatefulWidget {
  const PuzzlePickerScreen({super.key});

  @override
  State<PuzzlePickerScreen> createState() => _PuzzlePickerScreenState();
}

class _PuzzlePickerScreenState extends State<PuzzlePickerScreen> {
  late AppServices _services;
  (PuzzleDefinition, SavedGameSummary)? _mostRecentSavedGame;
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
    (PuzzleDefinition, SavedGameSummary)? mostRecentSavedGame;
    for (final puzzleKind in PuzzleKind.values) {
      final definition = puzzleKind.definition;
      final savedGame = await definition.loadSavedGame(_services);
      if (savedGame == null) continue;
      if (mostRecentSavedGame == null ||
          savedGame.savedAt.isAfter(mostRecentSavedGame.$2.savedAt)) {
        mostRecentSavedGame = (definition, savedGame);
      }
    }
    if (mounted) {
      setState(() => _mostRecentSavedGame = mostRecentSavedGame);
    }
  }

  Future<void> _openScreenThenRefresh(Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
    await _loadSavedGame();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final mostRecentSavedGame = _mostRecentSavedGame;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.appTitle,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
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
                if (mostRecentSavedGame case (
                  final definition,
                  final savedGame,
                )) ...[
                  ContinueCard(
                    savedGame: savedGame,
                    puzzleName: strings.puzzleName(definition.kind),
                    difficultyName: definition.difficultyName(
                      strings,
                      savedGame.difficulty,
                    ),
                    onTap: () => _openScreenThenRefresh(
                      definition.buildGameScreen(
                        definition.resumeGame(savedGame),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                for (final puzzleKind in PuzzleKind.values) ...[
                  _PuzzleCard(
                    puzzleKind: puzzleKind,
                    onTap: () => _openScreenThenRefresh(
                      PuzzleHomeScreen(definition: puzzleKind.definition),
                    ),
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
              puzzleKind.definition.buildLogo(size: 64),
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
