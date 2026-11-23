import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_services.dart';
import '../game/game_options.dart';
import '../l10n/localized_labels.dart';
import '../puzzles/puzzle_definition.dart';
import '../widgets/celebration.dart';

enum _GameMenuAction { restart, hint, howToPlay, settings }

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({
    super.key,
    required this.definition,
    required this.controller,
  });

  final PuzzleDefinition definition;
  final AnyPuzzleGameController controller;

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen>
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

  AnyPuzzleGameController get _controller => widget.controller;

  PuzzleDefinition get _definition => widget.definition;

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
    if (_controller.activeHintPointsAtWrongCell) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.strings.wrongCellHint)));
    }
  }

  Future<void> _celebrateThenShowSolvedDialog() async {
    final services = _services!;
    final solveTime = _controller.elapsed;
    final isNewBestTime = services.statisticsRepository.recordSolve(
      _controller.puzzleKind,
      _controller.size,
      _controller.difficulty,
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
    final services = _services;
    if (services == null) return;
    if (_controller.isSolved) {
      _definition.clearSavedGame(services);
      return;
    }
    _definition.saveGame(services, _controller);
  }

  Future<void> _showSolvedDialog(Duration solveTime, bool isNewBestTime) async {
    if (!mounted) return;
    final strings = context.strings;
    final formattedSolveTime = formatElapsedTime(solveTime);
    final goHome = await showDialog<bool>(
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
    if (goHome == true && mounted) {
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

  void _openScreen(Widget screen) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => screen));

  void _onMenuSelected(_GameMenuAction action) {
    switch (action) {
      case _GameMenuAction.restart:
        _confirmRestart();
      case _GameMenuAction.hint:
        _showHint();
      case _GameMenuAction.howToPlay:
        _openScreen(_definition.buildHowToPlayScreen());
      case _GameMenuAction.settings:
        _openScreen(_definition.buildSettingsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = AppScope.of(context).settingsController;
    final strings = context.strings;
    final size = _controller.size;
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, settingsController]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(
            '$size×$size · '
            '${_definition.difficultyName(strings, _controller.difficulty)}',
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
                Positioned.fill(
                  child: _definition.buildBoardArea(
                    context,
                    _controller,
                    _celebrationController,
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
