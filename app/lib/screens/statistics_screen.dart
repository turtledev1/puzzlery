import 'package:binairo_core/binairo_core.dart';
import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../game/game_options.dart';
import '../l10n/localized_labels.dart';
import '../statistics/statistics_repository.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<(int, Difficulty), PuzzleStatistics>? _statisticsByPuzzleKind;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statisticsByPuzzleKind == null) {
      _loadStatistics();
    }
  }

  StatisticsRepository get _repository =>
      AppScope.of(context).statisticsRepository;

  Future<void> _loadStatistics() async {
    final repository = _repository;
    final loaded = {
      for (final difficulty in Difficulty.values)
        for (final size in availableBoardSizes)
          (size, difficulty): await repository.load(size, difficulty),
    };
    if (mounted) {
      setState(() => _statisticsByPuzzleKind = loaded);
    }
  }

  Future<void> _confirmReset() async {
    final strings = context.strings;
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.resetStatisticsTitle),
        content: Text(strings.resetStatisticsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.reset),
          ),
        ],
      ),
    );
    if (shouldReset == true) {
      await _repository.clearAll();
      await _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statisticsByPuzzleKind = _statisticsByPuzzleKind;
    final strings = context.strings;
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.statistics),
        actions: [
          IconButton(
            tooltip: strings.resetStatisticsTooltip,
            icon: const Icon(Icons.delete_outline),
            onPressed: _confirmReset,
          ),
        ],
      ),
      body: statisticsByPuzzleKind == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding:
                  const EdgeInsets.all(16) +
                  EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              children: [
                for (final difficulty in Difficulty.values)
                  _DifficultyStatisticsCard(
                    difficulty: difficulty,
                    statisticsBySize: {
                      for (final size in availableBoardSizes)
                        size: statisticsByPuzzleKind[(size, difficulty)]!,
                    },
                  ),
              ],
            ),
    );
  }
}

class _DifficultyStatisticsCard extends StatelessWidget {
  const _DifficultyStatisticsCard({
    required this.difficulty,
    required this.statisticsBySize,
  });

  final Difficulty difficulty;
  final Map<int, PuzzleStatistics> statisticsBySize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final strings = context.strings;
    final headerStyle = textTheme.labelMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    String timeOrDash(Duration? time) =>
        time == null ? '–' : formatElapsedTime(time);
    TableRow row(List<String> cells, {TextStyle? style}) => TableRow(
      children: [
        for (final cell in cells)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(cell, style: style),
          ),
      ],
    );
    return Card.outlined(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.difficultyName(difficulty),
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Table(
              children: [
                row([
                  strings.boardSize,
                  strings.statisticsSolvedCount,
                  strings.statisticsBestTime,
                  strings.statisticsAverageTime,
                ], style: headerStyle),
                for (final MapEntry(key: size, value: statistics)
                    in statisticsBySize.entries)
                  row([
                    '$size×$size',
                    '${statistics.solvedCount}',
                    timeOrDash(statistics.bestTime),
                    timeOrDash(statistics.averageTime),
                  ], style: textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
