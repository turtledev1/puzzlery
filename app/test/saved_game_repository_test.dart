import 'package:binairo_core/binairo_core.dart' as binairo;
import 'package:flutter_test/flutter_test.dart';
import 'package:puzzlery_app/game/binairo_saved_game.dart';
import 'package:puzzlery_app/game/saved_game_repository.dart';
import 'package:puzzlery_app/game/sudoku_game_state.dart';
import 'package:puzzlery_app/game/sudoku_saved_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku_core/sudoku_core.dart' as sudoku;

import 'test_puzzles.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final savedAt = DateTime.utc(2026, 11, 23, 10, 30);

  group('binairo', () {
    test('loading with nothing saved returns null', () async {
      expect(await const BinairoSavedGameRepository().load(), isNull);
    });

    test(
      'a saved game loads back with the same puzzle, board, time and save time',
      () async {
        final puzzle = fourByFourBinairoPuzzleMissingCells(const [
          binairo.CellPosition(0, 0),
        ]);
        const repository = BinairoSavedGameRepository();

        await repository.save(
          BinairoSavedGame(
            puzzle: puzzle,
            currentBoard: puzzle.givenBoard.withCell(
              0,
              0,
              binairo.CellValue.one,
            ),
            elapsed: const Duration(seconds: 75),
            savedAt: savedAt,
          ),
        );
        final loaded = await repository.load();

        expect(loaded!.puzzle.givenBoard, puzzle.givenBoard);
        expect(loaded.puzzle.solutionBoard, puzzle.solutionBoard);
        expect(loaded.puzzle.difficulty, binairo.Difficulty.easy);
        expect(loaded.currentBoard.cellAt(0, 0), binairo.CellValue.one);
        expect(loaded.elapsed, const Duration(seconds: 75));
        expect(loaded.savedAt.isAtSameMomentAs(savedAt), isTrue);
      },
    );

    test('clearing removes the saved game', () async {
      const repository = BinairoSavedGameRepository();
      final puzzle = fourByFourBinairoPuzzleMissingCells(const []);
      await repository.save(
        BinairoSavedGame(
          puzzle: puzzle,
          currentBoard: puzzle.givenBoard,
          elapsed: Duration.zero,
          savedAt: savedAt,
        ),
      );

      await repository.clear();

      expect(await repository.load(), isNull);
    });

    test('fill progress counts only the cells the player had to fill', () {
      final puzzle = fourByFourBinairoPuzzleMissingCells(const [
        binairo.CellPosition(0, 0),
        binairo.CellPosition(1, 1),
        binairo.CellPosition(2, 2),
        binairo.CellPosition(3, 3),
      ]);

      final savedGame = BinairoSavedGame(
        puzzle: puzzle,
        currentBoard: puzzle.givenBoard.withCell(0, 0, binairo.CellValue.zero),
        elapsed: Duration.zero,
        savedAt: savedAt,
      );

      expect(savedGame.fillProgress, 0.25);
    });
  });

  group('sudoku', () {
    test(
      'a saved game loads back with the same puzzle, digits and notes',
      () async {
        final puzzle = fourByFourSudokuPuzzleMissingCells(const [
          sudoku.CellPosition(0, 0),
          sudoku.CellPosition(3, 3),
        ]);
        const repository = SudokuSavedGameRepository();
        final currentState = SudokuGameState.withoutNotes(
          puzzle.givenBoard,
        ).withDigit(0, 0, 1).withNoteToggled(3, 3, 1).withNoteToggled(3, 3, 4);

        await repository.save(
          SudokuSavedGame(
            puzzle: puzzle,
            currentState: currentState,
            elapsed: const Duration(seconds: 42),
            savedAt: savedAt,
          ),
        );
        final loaded = await repository.load();

        expect(loaded!.puzzle.givenBoard, puzzle.givenBoard);
        expect(loaded.puzzle.solutionBoard, puzzle.solutionBoard);
        expect(loaded.puzzle.difficulty, sudoku.Difficulty.easy);
        expect(loaded.currentState, currentState);
        expect(loaded.currentState.notedDigitsAt(3, 3), [1, 4]);
        expect(loaded.elapsed, const Duration(seconds: 42));
        expect(loaded.savedAt.isAtSameMomentAs(savedAt), isTrue);
      },
    );

    test('fill progress ignores notes', () {
      final puzzle = fourByFourSudokuPuzzleMissingCells(const [
        sudoku.CellPosition(0, 0),
        sudoku.CellPosition(3, 3),
      ]);

      final savedGame = SudokuSavedGame(
        puzzle: puzzle,
        currentState: SudokuGameState.withoutNotes(
          puzzle.givenBoard,
        ).withDigit(0, 0, 1).withNoteToggled(3, 3, 2),
        elapsed: Duration.zero,
        savedAt: savedAt,
      );

      expect(savedGame.fillProgress, 0.5);
    });
  });

  test('each puzzle keeps its own saved game', () async {
    final binairoPuzzle = fourByFourBinairoPuzzleMissingCells(const []);
    await const BinairoSavedGameRepository().save(
      BinairoSavedGame(
        puzzle: binairoPuzzle,
        currentBoard: binairoPuzzle.givenBoard,
        elapsed: Duration.zero,
        savedAt: savedAt,
      ),
    );

    expect(await const SudokuSavedGameRepository().load(), isNull);
    await const SudokuSavedGameRepository().clear();
    expect(await const BinairoSavedGameRepository().load(), isNotNull);
  });

  for (final (description, corruptSavedText) in [
    ('text that is not JSON', 'not json'),
    ('JSON that is not an object', '[1, 2]'),
    (
      'a board that does not parse',
      '{"difficulty":"easy","givenBoard":"not a board",'
          '"solutionBoard":"1234\\n3412\\n2143\\n4321",'
          '"currentBoard":"1234\\n3412\\n2143\\n4321","noteMasks":[],'
          '"elapsedSeconds":0,"savedAtMilliseconds":0}',
    ),
    (
      'notes that are not numbers',
      '{"difficulty":"easy","givenBoard":"1234\\n3412\\n2143\\n4321",'
          '"solutionBoard":"1234\\n3412\\n2143\\n4321",'
          '"currentBoard":"1234\\n3412\\n2143\\n4321","noteMasks":["x"],'
          '"elapsedSeconds":0,"savedAtMilliseconds":0}',
    ),
    (
      'a missing field',
      '{"difficulty":"easy","givenBoard":"1234\\n3412\\n2143\\n4321"}',
    ),
  ]) {
    test(
      'a corrupt saved game with $description is dropped instead of crashing',
      () async {
        SharedPreferences.setMockInitialValues({
          'saved_game.sudoku': corruptSavedText,
        });
        const repository = SudokuSavedGameRepository();

        expect(await repository.load(), isNull);
        final preferences = await SharedPreferences.getInstance();
        expect(preferences.containsKey('saved_game.sudoku'), isFalse);
      },
    );
  }

  test('fillProgressOf counts a board with nothing to fill as full', () {
    expect(
      fillProgressOf(cellCount: 16, givenCellCount: 16, filledCellCount: 16),
      1,
    );
  });
}
