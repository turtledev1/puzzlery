import 'package:shared_preferences/shared_preferences.dart';

import '../puzzles/puzzle_kind.dart';

class PuzzleStatistics {
  const PuzzleStatistics({
    this.solvedCount = 0,
    this.bestTime,
    this.totalTime = Duration.zero,
  });

  final int solvedCount;
  final Duration? bestTime;
  final Duration totalTime;

  Duration? get averageTime =>
      solvedCount == 0 ? null : totalTime ~/ solvedCount;
}

/// Difficulties are [Enum] so the `Difficulty` of every puzzle package fits.
class StatisticsRepository {
  static const String _keyPrefix = 'statistics';

  Future<PuzzleStatistics> load(
    PuzzleKind puzzleKind,
    int size,
    Enum difficulty,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final keys = _StatisticsKeys(puzzleKind, size, difficulty);
    final bestSeconds = preferences.getInt(keys.bestSeconds);
    return PuzzleStatistics(
      solvedCount: preferences.getInt(keys.solvedCount) ?? 0,
      bestTime: bestSeconds == null ? null : Duration(seconds: bestSeconds),
      totalTime: Duration(seconds: preferences.getInt(keys.totalSeconds) ?? 0),
    );
  }

  /// Returns `true` when [solveTime] is the new best time.
  Future<bool> recordSolve(
    PuzzleKind puzzleKind,
    int size,
    Enum difficulty,
    Duration solveTime,
  ) async {
    final previous = await load(puzzleKind, size, difficulty);
    final preferences = await SharedPreferences.getInstance();
    final keys = _StatisticsKeys(puzzleKind, size, difficulty);
    final previousBest = previous.bestTime;
    final newBest = previousBest == null || solveTime < previousBest
        ? solveTime
        : previousBest;
    await preferences.setInt(keys.solvedCount, previous.solvedCount + 1);
    await preferences.setInt(keys.bestSeconds, newBest.inSeconds);
    await preferences.setInt(
      keys.totalSeconds,
      (previous.totalTime + solveTime).inSeconds,
    );
    return newBest == solveTime;
  }

  Future<void> clearAll(PuzzleKind puzzleKind) async {
    final preferences = await SharedPreferences.getInstance();
    final puzzleKeyPrefix = '$_keyPrefix.${puzzleKind.name}.';
    final statisticsKeys = preferences.getKeys().where(
      (key) => key.startsWith(puzzleKeyPrefix),
    );
    for (final key in statisticsKeys.toList()) {
      await preferences.remove(key);
    }
  }
}

class _StatisticsKeys {
  _StatisticsKeys(PuzzleKind puzzleKind, int size, Enum difficulty)
    : _base =
          '${StatisticsRepository._keyPrefix}.${puzzleKind.name}.'
          '$size.${difficulty.name}';

  final String _base;

  String get solvedCount => '$_base.solved_count';
  String get bestSeconds => '$_base.best_seconds';
  String get totalSeconds => '$_base.total_seconds';
}
