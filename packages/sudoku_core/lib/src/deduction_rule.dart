/// Deductions a person can make, ordered from simplest to hardest.
/// A unit is a row, a column or a box.
enum DeductionRule {
  /// A digit fits in only one cell of a unit.
  hiddenSingle,

  /// A cell has only one digit left that its row, column and box allow.
  nakedSingle,

  /// A digit that a box allows only on one line is removed from the rest of
  /// that line, and a digit that a line allows only in one box is removed
  /// from the rest of that box.
  lockedCandidates,

  /// Two cells of a unit allow the same two digits only, so no other cell of
  /// the unit can take them.
  nakedPair,

  /// Two digits fit only in the same two cells of a unit, so those cells
  /// cannot take any other digit.
  hiddenPair,

  /// Like [nakedPair], with three cells and three digits.
  nakedTriple,

  /// Like [hiddenPair], with three digits and three cells.
  hiddenTriple,

  /// A digit fits in exactly the same two columns of two rows, so it is
  /// removed from the rest of those columns. Also with rows and columns
  /// swapped.
  xWing,
}
