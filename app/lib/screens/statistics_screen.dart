import 'package:flutter/material.dart';

import '../app/app_services.dart';
import '../game/game_options.dart';
import '../l10n/localized_labels.dart';
import '../puzzles/puzzle_definition.dart';
import '../statistics/statistics_repository.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key, required this.definition});

  final PuzzleDefinition definition;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<(int, Enum), PuzzleStatistics>? _statisticsBySizeAndDifficulty;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_statisticsBySizeAndDifficulty == null) {
      _loadStatistics();
    }
  }

  StatisticsRepository get _repository =>
      AppScope.of(context).statisticsRepository;

  PuzzleDefinition get _definition => widget.definition;

  Future<void> _loadStatistics() async {
    final repository = _repository;
    final loaded = {
      for (final difficulty in _definition.difficulties)
        for (final size in _definition.boardSizes)
          (size, difficulty): await repository.load(
            _definition.kind,
            size,
            difficulty,
          ),
    };
    if (mounted) {
      setState(() => _statisticsBySizeAndDifficulty = loaded);
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
      await _repository.clearAll(_definition.kind);
      await _loadStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final statisticsBySizeAndDifficulty = _statisticsBySizeAndDifficulty;
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
      body: statisticsBySizeAndDifficulty == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding:
                  const EdgeInsets.all(16) +
                  EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              children: [
                for (final difficulty in _definition.difficulties)
                  _DifficultyStatisticsCard(
                    difficultyName: _definition.difficultyName(
                      strings,
                      difficulty,
                    ),
                    statisticsBySize: {
                      for (final size in _definition.boardSizes)
                        size:
                            statisticsBySizeAndDifficulty[(size, difficulty)]!,
                    },
                  ),
              ],
            ),
    );
  }
}

class _DifficultyStatisticsCard extends StatelessWidget {
  const _DifficultyStatisticsCard({
    required this.difficultyName,
    required this.statisticsBySize,
  });

  final String difficultyName;
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
            Text(difficultyName, style: textTheme.titleLarge),
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
