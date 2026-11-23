import 'package:flutter/foundation.dart';

import '../puzzles/puzzle_kind.dart';

/// [GameState] needs value equality: [canRestart] compares it with
/// [startingState].
abstract class PuzzleGameController<
  GameState extends Object,
  HintType extends Object
>
    extends ChangeNotifier {
  PuzzleGameController({
    required this.startingState,
    GameState? currentState,
    this._elapsedBeforeThisSession = Duration.zero,
  }) : _currentState = currentState ?? startingState {
    _refreshDerivedState();
    if (!_isSolved) {
      _sessionStopwatch.start();
    }
  }

  final GameState startingState;
  final List<GameState> _previousStates = [];
  final Stopwatch _sessionStopwatch = Stopwatch();
  final Duration _elapsedBeforeThisSession;
  GameState _currentState;
  HintType? _activeHint;
  bool _isSolved = false;

  PuzzleKind get puzzleKind;

  int get size;

  Enum get difficulty;

  GameState get currentState => _currentState;

  bool get isSolved => _isSolved;

  HintType? get activeHint => _activeHint;

  bool get activeHintPointsAtWrongCell {
    final hint = _activeHint;
    return hint != null && isWrongCellHint(hint);
  }

  bool get canUndo => _previousStates.isNotEmpty && !_isSolved;

  bool get canRestart => !_isSolved && _currentState != startingState;

  Duration get elapsed => _elapsedBeforeThisSession + _sessionStopwatch.elapsed;

  /// Returns whether [state] solves the puzzle.
  @protected
  bool refreshRuleChecks(GameState state);

  @protected
  HintType? findHint(GameState state);

  @protected
  bool isWrongCellHint(HintType hint);

  @protected
  void moveTo(GameState nextState) {
    _previousStates.add(_currentState);
    _currentState = nextState;
    _refreshDerivedState();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) {
      return;
    }
    _currentState = _previousStates.removeLast();
    _refreshDerivedState();
    notifyListeners();
  }

  void restart() {
    if (!canRestart) {
      return;
    }
    moveTo(startingState);
  }

  void requestHint() {
    if (_isSolved) {
      return;
    }
    _activeHint = findHint(_currentState);
    notifyListeners();
  }

  void _refreshDerivedState() {
    _activeHint = null;
    _isSolved = refreshRuleChecks(_currentState);
    if (_isSolved) {
      _sessionStopwatch.stop();
    }
  }

  @override
  void dispose() {
    _sessionStopwatch.stop();
    super.dispose();
  }
}
