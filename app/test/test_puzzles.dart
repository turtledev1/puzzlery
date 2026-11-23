import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

final binairo.Board fourByFourBinairoSolution = binairo.Board.parse(
  '0101\n1010\n0110\n1001',
);

binairo.Puzzle fourByFourBinairoPuzzleMissingCells(
  List<binairo.CellPosition> missingCells,
) {
  var givenBoard = fourByFourBinairoSolution;
  for (final position in missingCells) {
    givenBoard = givenBoard.withCell(
      position.row,
      position.column,
      binairo.CellValue.empty,
    );
  }
  return binairo.Puzzle(
    difficulty: binairo.Difficulty.easy,
    givenBoard: givenBoard,
    solutionBoard: fourByFourBinairoSolution,
  );
}

final sudoku.Board fourByFourSudokuSolution = sudoku.Board.parse(
  '1234\n3412\n2143\n4321',
);

sudoku.Puzzle fourByFourSudokuPuzzleMissingCells(
  List<sudoku.CellPosition> missingCells,
) {
  var givenBoard = fourByFourSudokuSolution;
  for (final position in missingCells) {
    givenBoard = givenBoard.withCell(
      position.row,
      position.column,
      sudoku.Board.emptyValue,
    );
  }
  return sudoku.Puzzle(
    difficulty: sudoku.Difficulty.easy,
    givenBoard: givenBoard,
    solutionBoard: fourByFourSudokuSolution,
  );
}
