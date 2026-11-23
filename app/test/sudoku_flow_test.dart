import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlery_app/game/binairo_saved_game.dart';
import 'package:puzzlery_app/game/sudoku_game_state.dart';
import 'package:puzzlery_app/game/sudoku_saved_game.dart';
import 'package:puzzlery_app/puzzles/puzzle_kind.dart';
import 'package:puzzlery_app/widgets/hint_pulse.dart';
import 'package:puzzlery_app/widgets/puzzle_colors.dart';
import 'package:puzzlery_app/widgets/sudoku_board_cell.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

import 'test_app.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  SudokuBoardCell sudokuCell(WidgetTester tester, int row, int column) =>
      tester.widget<SudokuBoardCell>(find.byKey(ValueKey('cell-$row-$column')));

  bool isButtonEnabled(WidgetTester tester, String buttonKey) =>
      tester.widget<ButtonStyleButton>(find.byKey(ValueKey(buttonKey))).enabled;

  group('sudoku home', () {
    testWidgets('the Sudoku card opens the Sudoku home with its name, '
        'new game and the three shortcuts', (tester) async {
      await pumpPuzzleryAppOnSudokuHome(tester);

      expect(find.text('Sudoku'), findsOneWidget);
      expect(
        find.text('A logic puzzle of rows, columns and boxes'),
        findsOneWidget,
      );
      expect(find.text('New game'), findsOneWidget);
      expect(find.text('How to play'), findsOneWidget);
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('the new game sheet offers the Sudoku sizes, and the choice '
        'is remembered for Sudoku only', (tester) async {
      final requestedPuzzles = <(int, sudoku.Difficulty)>[];
      final services = await pumpPuzzleryAppOnSudokuHome(
        tester,
        requestedPuzzles: requestedPuzzles,
      );

      await tester.tap(find.text('New game'));
      await tester.pumpAndSettle();
      expect(find.text('4×4'), findsOneWidget);
      expect(find.text('6×6'), findsOneWidget);
      expect(find.text('9×9'), findsOneWidget);
      expect(find.text('12×12'), findsNothing);
      expect(find.textContaining('one digit left'), findsOneWidget);
      await tester.tap(find.text('6×6'));
      await tester.tap(find.text('Hard'));
      await tester.pump();
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(requestedPuzzles, [(6, sudoku.Difficulty.hard)]);
      final settings = services.settingsController.settings;
      expect(settings.sudokuLastBoardSize, 6);
      expect(settings.sudokuLastDifficulty, sudoku.Difficulty.hard);
      expect(settings.binairoLastBoardSize, 8);
      expect(settings.binairoLastDifficulty, binairo.Difficulty.easy);
    });

    testWidgets('each shortcut opens the Sudoku version of its screen', (
      tester,
    ) async {
      await pumpPuzzleryAppOnSudokuHome(tester);

      await tester.tap(find.text('How to play'));
      await tester.pumpAndSettle();
      expect(find.text('Rule 1 · Once in each row'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Statistics'));
      await tester.pumpAndSettle();
      expect(find.text('9×9'), findsNWidgets(2));
      expect(find.text('12×12'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Sudoku settings'), findsOneWidget);
      expect(find.text('Show rule errors'), findsOneWidget);
      expect(find.text('Show counters'), findsNothing);
      expect(find.text('All settings'), findsOneWidget);
    });

    testWidgets('leaving an unfinished game shows a continue card that '
        'resumes its digits and notes', (tester) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);
      await enterSudokuDigit(tester, 0, 0, 1);
      await tapCell(tester, 3, 3);
      await tapSudokuPadButton(tester, 'notes-button');
      await tapSudokuPadButton(tester, 'digit-button-2');

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('50%'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(sudokuCell(tester, 0, 0).digit, 1);
      expect(sudokuCell(tester, 3, 3).notedDigits, [2]);
    });
  });

  group('sudoku game', () {
    testWidgets('digits stay off until a cell you can change is selected', (
      tester,
    ) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);
      expect(isButtonEnabled(tester, 'digit-button-1'), isFalse);

      await tapCell(tester, 1, 1);
      expect(isButtonEnabled(tester, 'digit-button-1'), isFalse);
      expect(isButtonEnabled(tester, 'erase-button'), isFalse);

      await tapCell(tester, 0, 0);
      expect(isButtonEnabled(tester, 'digit-button-1'), isTrue);
      expect(isButtonEnabled(tester, 'erase-button'), isTrue);
    });

    testWidgets('the pad has one digit per number on the board', (
      tester,
    ) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      expect(find.byKey(const ValueKey('digit-button-4')), findsOneWidget);
      expect(find.byKey(const ValueKey('digit-button-5')), findsNothing);
    });

    testWidgets('tapping a cell, then a digit, puts the digit in the cell', (
      tester,
    ) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      await enterSudokuDigit(tester, 0, 0, 3);

      expect(digitInCell(0, 0, '3'), findsOneWidget);
      expect(sudokuCell(tester, 0, 0).highlight, SudokuCellHighlight.selected);
    });

    testWidgets('selecting a cell lights up its row, column and box, and '
        'the cells with the same digit', (tester) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      await tapCell(tester, 1, 1);

      expect(
        sudokuCell(tester, 1, 3).highlight,
        SudokuCellHighlight.peerOfSelected,
      );
      expect(
        sudokuCell(tester, 3, 1).highlight,
        SudokuCellHighlight.peerOfSelected,
      );
      expect(
        sudokuCell(tester, 0, 0).highlight,
        SudokuCellHighlight.peerOfSelected,
      );
      expect(
        sudokuCell(tester, 0, 3).highlight,
        SudokuCellHighlight.sameDigitAsSelected,
      );
      expect(sudokuCell(tester, 2, 3).highlight, SudokuCellHighlight.none);
    });

    testWidgets('in notes mode, digits become small notes, and erase clears '
        'them', (tester) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);
      await tapCell(tester, 0, 0);

      await tapSudokuPadButton(tester, 'notes-button');
      await tapSudokuPadButton(tester, 'digit-button-1');
      await tapSudokuPadButton(tester, 'digit-button-3');

      expect(sudokuCell(tester, 0, 0).digit, sudoku.Board.emptyValue);
      expect(sudokuCell(tester, 0, 0).notedDigits, [1, 3]);

      await tapSudokuPadButton(tester, 'erase-button');
      expect(sudokuCell(tester, 0, 0).notedDigits, isEmpty);
    });

    testWidgets('undo takes back the last digit', (tester) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);
      await enterSudokuDigit(tester, 0, 0, 3);

      await tester.tap(find.byTooltip('Undo'));
      await tester.pump();

      expect(sudokuCell(tester, 0, 0).digit, sudoku.Board.emptyValue);
    });

    testWidgets('a digit already in its row gets a red ring, and the Sudoku '
        'switch hides it without changing Binairo', (tester) async {
      final services = await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      await enterSudokuDigit(tester, 0, 0, 3);
      expect(
        ruleErrorRingOfCell(tester, 0, 0)?.top.color,
        PuzzleColors.ruleViolation,
      );

      await services.settingsController.update(
        (settings) => settings.copyWith(sudokuShowRuleErrors: false),
      );
      await tester.pump();

      expect(ruleErrorRingOfCell(tester, 0, 0), isNull);
      expect(
        services.settingsController.settings.binairoShowRuleErrors,
        isTrue,
      );
    });

    testWidgets('the game menu opens the Sudoku how to play and settings', (
      tester,
    ) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      await openGameMenuItem(tester, 'How to play');
      expect(find.text('Rule 3 · Once in each box'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      await openGameMenuItem(tester, 'Settings');
      expect(find.text('Sudoku settings'), findsOneWidget);
    });

    testWidgets('a hint from the menu makes an empty cell glow', (
      tester,
    ) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      await tester.tap(find.byTooltip('Menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hint'));
      await tester.pump(const Duration(milliseconds: 500));

      final glowingCell = find.byType(HintPulse);
      expect(glowingCell, findsOneWidget);
      final glowKey = tester.widget<HintPulse>(glowingCell).key;
      expect(
        glowKey,
        anyOf(const ValueKey('hint-0-0'), const ValueKey('hint-3-3')),
      );
    });

    testWidgets('solving celebrates, counts the solve for Sudoku only and '
        'removes the continue card', (tester) async {
      final services = await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      await solveSudokuPuzzleMissingTwoCells(tester);
      await tester.pumpAndSettle();
      expect(find.text('Solved!'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Home'));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsNothing);
      final statistics = services.statisticsRepository;
      expect(
        (await statistics.load(
          PuzzleKind.sudoku,
          4,
          sudoku.Difficulty.easy,
        )).solvedCount,
        1,
      );
      expect(
        (await statistics.load(
          PuzzleKind.binairo,
          4,
          binairo.Difficulty.easy,
        )).solvedCount,
        0,
      );
    });
  });

  group('sudoku tap feedback', () {
    late List<String> hapticTypes;

    setUp(() {
      hapticTypes = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              hapticTypes.add(call.arguments as String);
            }
            return null;
          });
    });

    tearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    testWidgets('selecting a cell gives no buzz, entering a digit gives one', (
      tester,
    ) async {
      await pumpPuzzleryAppOnSudokuHome(tester);
      await startNewGameFromHome(tester);

      await tapCell(tester, 0, 0);
      expect(hapticTypes, isEmpty);

      await tapSudokuPadButton(tester, 'digit-button-3');
      expect(hapticTypes, ['HapticFeedbackType.mediumImpact']);
    });
  });

  group('puzzle picker with two puzzles', () {
    final earlier = DateTime.utc(2026, 11, 23, 9);
    final later = DateTime.utc(2026, 11, 23, 10);

    Future<void> saveOneGameOfEachPuzzle({
      required DateTime binairoSavedAt,
      required DateTime sudokuSavedAt,
    }) async {
      await const BinairoSavedGameRepository().save(
        BinairoSavedGame(
          puzzle: binairoPuzzleMissingTwoCells,
          currentBoard: binairoPuzzleMissingTwoCells.givenBoard,
          elapsed: Duration.zero,
          savedAt: binairoSavedAt,
        ),
      );
      await const SudokuSavedGameRepository().save(
        SudokuSavedGame(
          puzzle: sudokuPuzzleMissingTwoCells,
          currentState: SudokuGameState.withoutNotes(
            sudokuPuzzleMissingTwoCells.givenBoard,
          ),
          elapsed: Duration.zero,
          savedAt: sudokuSavedAt,
        ),
      );
    }

    testWidgets('the continue card shows the Sudoku game when it was played '
        'last, and opens it', (tester) async {
      await saveOneGameOfEachPuzzle(
        binairoSavedAt: earlier,
        sudokuSavedAt: later,
      );

      await pumpPuzzleryApp(tester);
      expect(find.textContaining('Sudoku · 4×4 · Easy'), findsOneWidget);
      expect(find.textContaining('Binairo · 4×4'), findsNothing);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('digit-button-1')), findsOneWidget);
    });

    testWidgets('the continue card shows the Binairo game when it was played '
        'last', (tester) async {
      await saveOneGameOfEachPuzzle(
        binairoSavedAt: later,
        sudokuSavedAt: earlier,
      );

      await pumpPuzzleryApp(tester);

      expect(find.textContaining('Binairo · 4×4 · Easy'), findsOneWidget);
      expect(find.textContaining('Sudoku · 4×4'), findsNothing);
    });

    testWidgets('each puzzle home shows only its own saved game', (
      tester,
    ) async {
      await saveOneGameOfEachPuzzle(
        binairoSavedAt: later,
        sudokuSavedAt: earlier,
      );
      await pumpPuzzleryApp(tester);

      await openPuzzleFromPicker(tester, 'sudoku');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('digit-button-1')), findsOneWidget);
    });
  });
}
