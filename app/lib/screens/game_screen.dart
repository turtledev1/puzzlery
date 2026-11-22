import 'dart:async';

import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_services.dart';
import '../game/game_controller.dart';
import '../game/game_options.dart';
import '../game/saved_game_repository.dart';
import '../l10n/localized_labels.dart';
import '../widgets/board_grid.dart';
import '../widgets/celebration.dart';
import 'how_to_play_screen.dart';
import 'settings_screen.dart';

enum _GameMenuAction { restart, hint, howToPlay, settings }

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.controller});

  final GameController controller;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const Duration celebrationDuration = Duration(milliseconds: 1800);

  late final AppLifecycleListener _appLifecycleListener;
  late final AnimationController _celebrationController = AnimationController(
    vsync: this,
    duration: celebrationDuration,
  );
  AppServices? _services;
  bool _hasCelebrated = false;
  Timer? _inactivityTimer;

  GameController get _controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onGameChanged);
    _appLifecycleListener = AppLifecycleListener(onPause: _saveProgress);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isFirstDependencyChange = _services == null;
    _services = AppScope.of(context);
    if (isFirstDependencyChange) {
      _services!.settingsController.addListener(_restartInactivityTimer);
      _saveProgress();
      _restartInactivityTimer();
    }
  }

  @override
  void dispose() {
    _saveProgress();
    _inactivityTimer?.cancel();
    _services?.settingsController.removeListener(_restartInactivityTimer);
    _appLifecycleListener.dispose();
    _celebrationController.dispose();
    _controller.removeListener(_onGameChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onGameChanged() {
    _saveProgress();
    _restartInactivityTimer();
    if (_controller.isSolved && !_hasCelebrated) {
      _hasCelebrated = true;
      _celebrateThenShowSolvedDialog();
    }
  }

  void _restartInactivityTimer() {
    _inactivityTimer?.cancel();
    final settings = _services?.settingsController.settings;
    final shouldWaitForHint =
        settings != null &&
        settings.autoHintEnabled &&
        !_controller.isSolved &&
        _controller.activeHint == null;
    if (!shouldWaitForHint) {
      return;
    }
    _inactivityTimer = Timer(settings.autoHintDelay, () {
      if (mounted && _controller.activeHint == null) {
        _showHint();
      }
    });
  }

  void _showHint() {
    _controller.requestHint();
    if (_controller.activeHint is WrongCellHint) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.strings.wrongCellHint)));
    }
  }

  Future<void> _celebrateThenShowSolvedDialog() async {
    final services = _services!;
    final solveTime = _controller.elapsed;
    final isNewBestTime = services.statisticsRepository.recordSolve(
      _controller.size,
      _controller.puzzle.difficulty,
      solveTime,
    );
    if (services.settingsController.settings.vibrationEnabled) {
      HapticFeedback.heavyImpact();
    }
    await _celebrationController.forward();
    if (mounted) {
      await _showSolvedDialog(solveTime, await isNewBestTime);
    }
  }

  void _saveProgress() {
    final savedGameRepository = _services?.savedGameRepository;
    if (savedGameRepository == null) return;
    if (_controller.isSolved) {
      savedGameRepository.clear();
      return;
    }
    savedGameRepository.save(
      SavedGame(
        puzzle: _controller.puzzle,
        currentBoard: _controller.currentBoard,
        elapsed: _controller.elapsed,
      ),
    );
  }

  Future<void> _showSolvedDialog(Duration solveTime, bool isNewBestTime) async {
    if (!mounted) return;
    final strings = context.strings;
    final formattedSolveTime = formatElapsedTime(solveTime);
    final startNewGame = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          isNewBestTime ? Icons.emoji_events : Icons.check_circle,
          size: 48,
        ),
        title: Text(strings.solvedTitle),
        content: Text(
          isNewBestTime
              ? strings.newBestTime(formattedSolveTime)
              : strings.solveTime(formattedSolveTime),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.lookAtBoard),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.home),
          ),
        ],
      ),
    );
    if (startNewGame == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirmRestart() async {
    final strings = context.strings;
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.restartTitle),
        content: Text(strings.restartMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.restart),
          ),
        ],
      ),
    );
    if (shouldRestart == true) {
      _controller.restart();
    }
  }

  void _onMenuSelected(_GameMenuAction action) {
    switch (action) {
      case _GameMenuAction.restart:
        _confirmRestart();
      case _GameMenuAction.hint:
        _showHint();
      case _GameMenuAction.howToPlay:
        Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const HowToPlayScreen()),
        );
      case _GameMenuAction.settings:
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = _controller.puzzle;
    final settingsController = AppScope.of(context).settingsController;
    final strings = context.strings;
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, settingsController]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            '${puzzle.size}×${puzzle.size} · '
            '${strings.difficultyName(puzzle.difficulty)}',
          ),
          actions: [
            IconButton(
              tooltip: strings.undo,
              icon: const Icon(Icons.undo),
              onPressed: _controller.canUndo ? _controller.undo : null,
            ),
            PopupMenuButton<_GameMenuAction>(
              tooltip: strings.menu,
              onSelected: _onMenuSelected,
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _GameMenuAction.restart,
                  enabled: _controller.canRestart,
                  child: ListTile(
                    leading: const Icon(Icons.restart_alt),
                    title: Text(strings.restart),
                  ),
                ),
                PopupMenuItem(
                  value: _GameMenuAction.hint,
                  enabled: !_controller.isSolved,
                  child: ListTile(
                    leading: const Icon(Icons.lightbulb_outline),
                    title: Text(strings.hint),
                  ),
                ),
                PopupMenuItem(
                  value: _GameMenuAction.howToPlay,
                  child: ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: Text(strings.howToPlay),
                  ),
                ),
                PopupMenuItem(
                  value: _GameMenuAction.settings,
                  child: ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: Text(strings.settings),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Stack(
              children: [
                Center(
                  child: BoardGrid(
                    controller: _controller,
                    celebration: _celebrationController,
                    showRuleErrors: settingsController.settings.showRuleErrors,
                    showLineCounters:
                        settingsController.settings.showLineCounters,
                    tapFeedbackEnabled:
                        settingsController.settings.vibrationEnabled,
                  ),
                ),
                Positioned.fill(
                  child: ConfettiOverlay(celebration: _celebrationController),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
