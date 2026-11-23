import 'deduction_rule.dart';

const Set<DeductionRule> _singles = {
  DeductionRule.hiddenSingle,
  DeductionRule.nakedSingle,
};

enum Difficulty {
  easy(allowedRules: _singles, minimumClueShare: 0.45),
  medium(allowedRules: _singles),
  hard(allowedRules: {...DeductionRule.values}, needsMoreThan: _singles);

  const Difficulty({
    required this.allowedRules,
    this.minimumClueShare = 0,
    this.needsMoreThan = const {},
  });

  final Set<DeductionRule> allowedRules;

  /// Clues are added back after the puzzle is minimal until at least this
  /// share of the cells are clues.
  final double minimumClueShare;

  /// When not empty, the generator retries puzzles that these rules alone can
  /// solve.
  final Set<DeductionRule> needsMoreThan;
}
