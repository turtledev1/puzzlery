import 'deduction_rule.dart';

enum Difficulty {
  easy({DeductionRule.hiddenSingle, DeductionRule.nakedSingle}),
  hard({...DeductionRule.values});

  const Difficulty(this.allowedRules);

  final Set<DeductionRule> allowedRules;
}
