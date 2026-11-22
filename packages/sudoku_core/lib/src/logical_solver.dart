import 'board.dart';
import 'deduction_engine.dart';
import 'deduction_rule.dart';

class LogicalSolveResult {
  const LogicalSolveResult({
    required this.board,
    required this.isSolved,
    required this.hasContradiction,
  });

  final Board board;
  final bool isSolved;
  final bool hasContradiction;
}

class LogicalSolver {
  LogicalSolver(this.allowedRules);

  final Set<DeductionRule> allowedRules;

  LogicalSolveResult solve(Board board) {
    final engine = DeductionEngine.fromBoard(board, allowedRules);
    final hasNoContradiction = engine.deduceUntilStuck();
    return LogicalSolveResult(
      board: engine.toBoard(),
      isSolved: hasNoContradiction && engine.isComplete,
      hasContradiction: !hasNoContradiction,
    );
  }

  bool canSolveCompletely(Board board) => solve(board).isSolved;
}
