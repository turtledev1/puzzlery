import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../game/game_controller.dart';
import '../game/saved_game_repository.dart';
import '../l10n/localized_labels.dart';
import '../puzzles/puzzle_kind.dart';
import '../widgets/app_logo.dart';
import '../widgets/continue_card.dart';
import '../widgets/new_game_sheet.dart';
import 'game_screen.dart';
import 'how_to_play_screen.dart';
import 'binairo_settings_screen.dart';
import 'statistics_screen.dart';

class BinairoHomeScreen extends StatefulWidget {
  const BinairoHomeScreen({super.key});

  @override
  State<BinairoHomeScreen> createState() => _BinairoHomeScreenState();
}

class _BinairoHomeScreenState extends State<BinairoHomeScreen> {
  late AppServices _services;
  SavedGame? _savedGame;
  bool _isGenerating = false;
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

  Future<void> _chooseAndStartNewGame() async {
    final settingsController = _services.settingsController;
    final choice = await showNewGameSheet(
      context,
      initialSize: settingsController.settings.lastBoardSize,
      initialDifficulty: settingsController.settings.lastDifficulty,
    );
    if (choice == null || !mounted) return;
    settingsController.update(
      (settings) => settings.copyWith(
        lastBoardSize: choice.size,
        lastDifficulty: choice.difficulty,
      ),
    );
    if (_savedGame != null && !await _confirmReplacingSavedGame()) return;

    setState(() => _isGenerating = true);
    final puzzle = await _services.puzzleFactory(
      choice.size,
      choice.difficulty,
    );
    if (!mounted) return;
    setState(() => _isGenerating = false);
    await _openGame(GameController(puzzle: puzzle));
  }

  Future<bool> _confirmReplacingSavedGame() async {
    final shouldReplace = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.strings.replaceSavedGameTitle),
        content: Text(context.strings.replaceSavedGameMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.strings.replaceSavedGameConfirm),
          ),
        ],
      ),
    );
    return shouldReplace == true;
  }

  Future<void> _openGame(GameController controller) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GameScreen(controller: controller),
      ),
    );
    await _loadSavedGame();
  }

  void _openScreen(Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final savedGame = _savedGame;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(size: 112)),
                  const SizedBox(height: 24),
                  Text(
                    strings.puzzleName(PuzzleKind.binairo),
                    textAlign: TextAlign.center,
                    style: textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.puzzleTagline(PuzzleKind.binairo),
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (savedGame != null) ...[
                    ContinueCard(
                      savedGame: savedGame,
                      onTap: _isGenerating
                          ? null
                          : () => _openGame(GameController.resume(savedGame)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: textTheme.titleMedium,
                    ),
                    onPressed: _isGenerating ? null : _chooseAndStartNewGame,
                    icon: _isGenerating
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add),
                    label: Text(
                      _isGenerating ? strings.makingPuzzle : strings.newGame,
                    ),
                  ),
                  const SizedBox(height: 24),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _HomeShortcut(
                          icon: Icons.school_outlined,
                          label: strings.howToPlay,
                          onTap: () => _openScreen(const HowToPlayScreen()),
                        ),
                        const SizedBox(width: 12),
                        _HomeShortcut(
                          icon: Icons.bar_chart,
                          label: strings.statistics,
                          onTap: () => _openScreen(const StatisticsScreen()),
                        ),
                        const SizedBox(width: 12),
                        _HomeShortcut(
                          icon: Icons.settings_outlined,
                          label: strings.settings,
                          onTap: () =>
                              _openScreen(const BinairoSettingsScreen()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeShortcut extends StatelessWidget {
  const _HomeShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card.outlined(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
