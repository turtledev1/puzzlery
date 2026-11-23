import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlery_app/app/app_services.dart';
import 'package:puzzlery_app/app/puzzlery_app.dart';
import 'package:puzzlery_app/settings/settings_controller.dart';
import 'package:puzzlery_app/statistics/statistics_repository.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

import 'test_puzzles.dart';

final binairo.Puzzle binairoPuzzleMissingTwoCells =
    fourByFourBinairoPuzzleMissingCells(const [
      binairo.CellPosition(0, 0),
      binairo.CellPosition(3, 3),
    ]);

/// Missing (0, 0) and (3, 3); both hold a 1 in the solution.
final sudoku.Puzzle sudokuPuzzleMissingTwoCells =
    fourByFourSudokuPuzzleMissingCells(const [
      sudoku.CellPosition(0, 0),
      sudoku.CellPosition(3, 3),
    ]);

Future<AppServices> pumpPuzzleryApp(
  WidgetTester tester, {
  List<(int, binairo.Difficulty)>? requestedBinairoPuzzles,
  List<(int, sudoku.Difficulty)>? requestedSudokuPuzzles,
}) async {
  final settingsController = await SettingsController.load();
  final services = AppServices(
    statisticsRepository: StatisticsRepository(),
    settingsController: settingsController,
    binairoPuzzleFactory: (size, difficulty) async {
      requestedBinairoPuzzles?.add((size, difficulty));
      return binairoPuzzleMissingTwoCells;
    },
    sudokuPuzzleFactory: (size, difficulty) async {
      requestedSudokuPuzzles?.add((size, difficulty));
      return sudokuPuzzleMissingTwoCells;
    },
  );
  await tester.pumpWidget(PuzzleryApp(services: services));
  await tester.pumpAndSettle();
  return services;
}

Future<AppServices> pumpPuzzleryAppOnBinairoHome(
  WidgetTester tester, {
  List<(int, binairo.Difficulty)>? requestedPuzzles,
}) async {
  final services = await pumpPuzzleryApp(
    tester,
    requestedBinairoPuzzles: requestedPuzzles,
  );
  await openPuzzleFromPicker(tester, 'binairo');
  return services;
}

Future<AppServices> pumpPuzzleryAppOnSudokuHome(
  WidgetTester tester, {
  List<(int, sudoku.Difficulty)>? requestedPuzzles,
}) async {
  final services = await pumpPuzzleryApp(
    tester,
    requestedSudokuPuzzles: requestedPuzzles,
  );
  await openPuzzleFromPicker(tester, 'sudoku');
  return services;
}

Future<void> openPuzzleFromPicker(
  WidgetTester tester,
  String puzzleName,
) async {
  final puzzleCard = find.byKey(ValueKey('puzzle-card-$puzzleName'));
  await tester.ensureVisible(puzzleCard);
  await tester.tap(puzzleCard);
  await tester.pumpAndSettle();
}

Future<void> startNewGameFromHome(
  WidgetTester tester, {
  String? sizeLabel,
  String? levelLabel,
}) async {
  await tester.tap(find.text('New game'));
  await tester.pumpAndSettle();
  if (sizeLabel != null) await tester.tap(find.text(sizeLabel));
  if (levelLabel != null) await tester.tap(find.text(levelLabel));
  await tester.pump();
  await tester.tap(find.text('Start'));
  await tester.pumpAndSettle();
}

Future<void> leaveGameAndPuzzleHome(WidgetTester tester) async {
  await tester.pageBack();
  await tester.pumpAndSettle();
  await tester.pageBack();
  await tester.pumpAndSettle();
}

Future<void> tapCell(WidgetTester tester, int row, int column) async {
  await tester.tap(find.byKey(ValueKey('cell-$row-$column')));
  await tester.pump();
}

Finder digitInCell(int row, int column, String digit) => find.descendant(
  of: find.byKey(ValueKey('cell-$row-$column')),
  matching: find.text(digit),
);

Future<void> solveBinairoPuzzleMissingTwoCells(WidgetTester tester) async {
  await tapCell(tester, 0, 0);
  await tapCell(tester, 3, 3);
  await tapCell(tester, 3, 3);
}

Future<void> tapSudokuPadButton(WidgetTester tester, String buttonKey) async {
  await tester.tap(find.byKey(ValueKey(buttonKey)));
  await tester.pump();
}

Future<void> enterSudokuDigit(
  WidgetTester tester,
  int row,
  int column,
  int digit,
) async {
  await tapCell(tester, row, column);
  await tapSudokuPadButton(tester, 'digit-button-$digit');
}

Future<void> solveSudokuPuzzleMissingTwoCells(WidgetTester tester) async {
  await enterSudokuDigit(tester, 0, 0, 1);
  await enterSudokuDigit(tester, 3, 3, 1);
}

Future<void> openGameMenuItem(WidgetTester tester, String label) async {
  await tester.tap(find.byTooltip('Menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

/// The first [Container] inside a cell draws the red rule-error ring.
Border? ruleErrorRingOfCell(WidgetTester tester, int row, int column) {
  final ring = tester.widget<Container>(
    find
        .descendant(
          of: find.byKey(ValueKey('cell-$row-$column')),
          matching: find.byType(Container),
        )
        .first,
  );
  return (ring.decoration as BoxDecoration?)?.border as Border?;
}
