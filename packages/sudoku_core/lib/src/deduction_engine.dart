import 'board.dart';
import 'board_geometry.dart';
import 'deduction_rule.dart';

/// Candidates are bit masks: digit `d` is bit `1 << d`.
int digitBit(int digit) => 1 << digit;

int countCandidates(int candidateMask) {
  var count = 0;
  for (
    var remaining = candidateMask;
    remaining != 0;
    remaining &= remaining - 1
  ) {
    count++;
  }
  return count;
}

List<int> digitsInMask(int candidateMask) => [
  for (var digit = 1; candidateMask >> digit != 0; digit++)
    if (candidateMask & digitBit(digit) != 0) digit,
];

class DeductionEngine {
  DeductionEngine(this.size, this.cellValues, Set<DeductionRule> allowedRules)
    : _geometry = BoardGeometry.forSize(size),
      _orderedAllowedRules = DeductionRule.values
          .where(allowedRules.contains)
          .toList(),
      candidateMasks = List.filled(size * size, 0) {
    _computeCandidatesFromCellValues();
  }

  factory DeductionEngine.fromBoard(
    Board board,
    Set<DeductionRule> allowedRules,
  ) => DeductionEngine(board.size, List.of(board.cells), allowedRules);

  final int size;
  final List<int> cellValues;

  /// Zero for filled cells.
  final List<int> candidateMasks;
  final BoardGeometry _geometry;
  final List<DeductionRule> _orderedAllowedRules;
  bool _hasFoundContradiction = false;
  bool _stopAtFirstPlacement = false;
  int? _firstPlacedCellIndex;

  bool get isComplete => !cellValues.contains(Board.emptyValue);

  bool get hasFoundContradiction => _hasFoundContradiction;

  bool get _mustStopApplying =>
      _hasFoundContradiction ||
      (_stopAtFirstPlacement && _firstPlacedCellIndex != null);

  Board toBoard() => Board.fromCells(size, cellValues);

  /// Returns `false` when the cells break a Sudoku rule.
  bool deduceUntilStuck() {
    var someRuleMadeProgress = true;
    while (someRuleMadeProgress && !_mustStopApplying) {
      someRuleMadeProgress = false;
      for (final rule in _orderedAllowedRules) {
        final ruleMadeProgress = applyRule(rule);
        if (_mustStopApplying) {
          break;
        }
        if (ruleMadeProgress) {
          someRuleMadeProgress = true;
          break;
        }
      }
    }
    return !_hasFoundContradiction;
  }

  /// Returns `null` when the rules get stuck first, or on a contradiction.
  int? deduceUntilFirstPlacement() {
    _stopAtFirstPlacement = true;
    deduceUntilStuck();
    return _hasFoundContradiction ? null : _firstPlacedCellIndex;
  }

  /// Returns `true` when it placed a digit or removed a candidate.
  bool applyRule(DeductionRule rule) {
    if (_hasFoundContradiction) {
      return false;
    }
    return switch (rule) {
      DeductionRule.hiddenSingle => _applyHiddenSingles(),
      DeductionRule.nakedSingle => _applyNakedSingles(),
      DeductionRule.lockedCandidates => _applyLockedCandidates(),
      DeductionRule.nakedPair => _applyNakedSubsets(2),
      DeductionRule.hiddenPair => _applyHiddenSubsets(2),
      DeductionRule.nakedTriple => _applyNakedSubsets(3),
      DeductionRule.hiddenTriple => _applyHiddenSubsets(3),
      DeductionRule.xWing => _applyXWings(),
    };
  }

  /// Empty when the board is full.
  List<int> emptyCellsWithFewestCandidates() {
    var fewestCandidates = size + 1;
    var cellsWithFewest = <int>[];
    for (var cell = 0; cell < cellValues.length; cell++) {
      if (cellValues[cell] != Board.emptyValue) continue;
      final candidateCount = countCandidates(candidateMasks[cell]);
      if (candidateCount < fewestCandidates) {
        fewestCandidates = candidateCount;
        cellsWithFewest = [cell];
      } else if (candidateCount == fewestCandidates) {
        cellsWithFewest.add(cell);
      }
    }
    return cellsWithFewest;
  }

  Set<int> candidateDigitsAt(int cellIndex) =>
      digitsInMask(candidateMasks[cellIndex]).toSet();

  void _computeCandidatesFromCellValues() {
    final allDigitsMask = ((1 << size) - 1) << 1;
    for (var cell = 0; cell < _geometry.cellCount; cell++) {
      final value = cellValues[cell];
      var mask = value == Board.emptyValue ? allDigitsMask : 0;
      for (final peer in _geometry.peersOfCell[cell]) {
        final peerValue = cellValues[peer];
        if (peerValue == Board.emptyValue) continue;
        if (peerValue == value) {
          _hasFoundContradiction = true;
        }
        mask &= ~digitBit(peerValue);
      }
      if (value == Board.emptyValue && mask == 0) {
        _hasFoundContradiction = true;
      }
      candidateMasks[cell] = mask;
    }
  }

  bool _place(int cellIndex, int digit) {
    final currentValue = cellValues[cellIndex];
    if (currentValue != Board.emptyValue) {
      if (currentValue != digit) {
        _hasFoundContradiction = true;
      }
      return false;
    }
    if (candidateMasks[cellIndex] & digitBit(digit) == 0) {
      _hasFoundContradiction = true;
      return false;
    }
    cellValues[cellIndex] = digit;
    candidateMasks[cellIndex] = 0;
    _firstPlacedCellIndex ??= cellIndex;
    for (final peer in _geometry.peersOfCell[cellIndex]) {
      _removeCandidates(peer, digitBit(digit));
    }
    return true;
  }

  bool _removeCandidates(int cellIndex, int digitsMaskToRemove) {
    if (cellValues[cellIndex] != Board.emptyValue) {
      return false;
    }
    final currentMask = candidateMasks[cellIndex];
    final reducedMask = currentMask & ~digitsMaskToRemove;
    if (reducedMask == currentMask) {
      return false;
    }
    candidateMasks[cellIndex] = reducedMask;
    if (reducedMask == 0) {
      _hasFoundContradiction = true;
    }
    return true;
  }

  bool _unitHasDigit(List<int> unit, int digit) =>
      unit.any((cell) => cellValues[cell] == digit);

  List<int> _cellsAllowingDigit(List<int> unit, int digit) => [
    for (final cell in unit)
      if (candidateMasks[cell] & digitBit(digit) != 0) cell,
  ];

  bool _applyHiddenSingles() {
    var anyProgress = false;
    for (final unit in _geometry.units) {
      for (var digit = 1; digit <= size; digit++) {
        if (_unitHasDigit(unit, digit)) continue;
        final cellsAllowingDigit = _cellsAllowingDigit(unit, digit);
        if (cellsAllowingDigit.isEmpty) {
          _hasFoundContradiction = true;
          return false;
        }
        if (cellsAllowingDigit.length == 1) {
          anyProgress = _place(cellsAllowingDigit.single, digit) || anyProgress;
          if (_mustStopApplying) return anyProgress;
        }
      }
    }
    return anyProgress;
  }

  bool _applyNakedSingles() {
    var anyProgress = false;
    for (var cell = 0; cell < _geometry.cellCount; cell++) {
      if (cellValues[cell] != Board.emptyValue) continue;
      final mask = candidateMasks[cell];
      if (countCandidates(mask) == 1) {
        anyProgress = _place(cell, mask.bitLength - 1) || anyProgress;
        if (_mustStopApplying) return anyProgress;
      }
    }
    return anyProgress;
  }

  bool _applyLockedCandidates() {
    var anyProgress = false;
    for (var box = 0; box < size; box++) {
      for (var digit = 1; digit <= size; digit++) {
        final cellsInBox = _cellsAllowingDigit(_geometry.boxes[box], digit);
        if (cellsInBox.isEmpty) continue;
        final lockedLines = [
          if (_allShare(cellsInBox, _geometry.rowOfCell))
            _geometry.rows[_geometry.rowOfCell[cellsInBox.first]],
          if (_allShare(cellsInBox, _geometry.columnOfCell))
            _geometry.columns[_geometry.columnOfCell[cellsInBox.first]],
        ];
        for (final line in lockedLines) {
          for (final cell in line) {
            if (_geometry.boxOfCell[cell] == box) continue;
            anyProgress =
                _removeCandidates(cell, digitBit(digit)) || anyProgress;
          }
          if (_hasFoundContradiction) return false;
        }
      }
    }
    for (final line in [..._geometry.rows, ..._geometry.columns]) {
      for (var digit = 1; digit <= size; digit++) {
        final cellsInLine = _cellsAllowingDigit(line, digit);
        if (cellsInLine.isEmpty ||
            !_allShare(cellsInLine, _geometry.boxOfCell)) {
          continue;
        }
        final lineCells = line.toSet();
        for (final cell
            in _geometry.boxes[_geometry.boxOfCell[cellsInLine.first]]) {
          if (lineCells.contains(cell)) continue;
          anyProgress = _removeCandidates(cell, digitBit(digit)) || anyProgress;
        }
        if (_hasFoundContradiction) return false;
      }
    }
    return anyProgress;
  }

  bool _allShare(List<int> cells, List<int> groupOfCell) =>
      cells.every((cell) => groupOfCell[cell] == groupOfCell[cells.first]);

  bool _applyNakedSubsets(int subsetSize) {
    var anyProgress = false;
    for (final unit in _geometry.units) {
      final smallEnoughCells = [
        for (final cell in unit)
          if (cellValues[cell] == Board.emptyValue &&
              countCandidates(candidateMasks[cell]) <= subsetSize)
            cell,
      ];
      for (final subset in _combinations(smallEnoughCells, subsetSize)) {
        final digitsOfSubset = subset.fold(
          0,
          (mask, cell) => mask | candidateMasks[cell],
        );
        if (countCandidates(digitsOfSubset) != subsetSize) continue;
        for (final cell in unit) {
          if (subset.contains(cell)) continue;
          anyProgress = _removeCandidates(cell, digitsOfSubset) || anyProgress;
        }
        if (_hasFoundContradiction) return false;
      }
    }
    return anyProgress;
  }

  bool _applyHiddenSubsets(int subsetSize) {
    var anyProgress = false;
    for (final unit in _geometry.units) {
      final cellsByDigit = <int, List<int>>{
        for (var digit = 1; digit <= size; digit++)
          if (!_unitHasDigit(unit, digit))
            digit: _cellsAllowingDigit(unit, digit),
      };
      final digitsInFewEnoughCells = [
        for (final MapEntry(key: digit, value: cells) in cellsByDigit.entries)
          if (cells.length >= 2 && cells.length <= subsetSize) digit,
      ];
      for (final digitSubset in _combinations(
        digitsInFewEnoughCells,
        subsetSize,
      )) {
        final cellsOfSubset = {
          for (final digit in digitSubset) ...cellsByDigit[digit]!,
        };
        if (cellsOfSubset.length != subsetSize) continue;
        final digitsMaskOfSubset = digitSubset.fold(
          0,
          (mask, digit) => mask | digitBit(digit),
        );
        for (final cell in cellsOfSubset) {
          anyProgress =
              _removeCandidates(cell, ~digitsMaskOfSubset) || anyProgress;
        }
      }
    }
    return anyProgress;
  }

  bool _applyXWings() {
    final rowsAcrossColumns = _applyXWingsWithBaseLines(
      _geometry.rows,
      _geometry.columnOfCell,
      _geometry.columns,
    );
    if (_hasFoundContradiction) return false;
    final columnsAcrossRows = _applyXWingsWithBaseLines(
      _geometry.columns,
      _geometry.rowOfCell,
      _geometry.rows,
    );
    return rowsAcrossColumns || columnsAcrossRows;
  }

  bool _applyXWingsWithBaseLines(
    List<List<int>> baseLines,
    List<int> coverLineOfCell,
    List<List<int>> coverLines,
  ) {
    var anyProgress = false;
    for (var digit = 1; digit <= size; digit++) {
      final baseLinesByCoverPair = <(int, int), List<int>>{};
      for (var baseLine = 0; baseLine < size; baseLine++) {
        final cells = _cellsAllowingDigit(baseLines[baseLine], digit);
        if (cells.length != 2) continue;
        final coverPair = (
          coverLineOfCell[cells.first],
          coverLineOfCell[cells.last],
        );
        baseLinesByCoverPair.putIfAbsent(coverPair, () => []).add(baseLine);
      }
      for (final MapEntry(key: coverPair, value: matchingBaseLines)
          in baseLinesByCoverPair.entries) {
        if (matchingBaseLines.length != 2) continue;
        final baseCells = {
          for (final baseLine in matchingBaseLines) ...baseLines[baseLine],
        };
        for (final coverLine in [coverPair.$1, coverPair.$2]) {
          for (final cell in coverLines[coverLine]) {
            if (baseCells.contains(cell)) continue;
            anyProgress =
                _removeCandidates(cell, digitBit(digit)) || anyProgress;
          }
        }
        if (_hasFoundContradiction) return false;
      }
    }
    return anyProgress;
  }
}

Iterable<List<int>> _combinations(List<int> items, int count) sync* {
  if (count == 0) {
    yield const [];
    return;
  }
  for (var first = 0; first <= items.length - count; first++) {
    for (final rest in _combinations(items.sublist(first + 1), count - 1)) {
      yield [items[first], ...rest];
    }
  }
}
