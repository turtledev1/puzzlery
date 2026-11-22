# Puzzlery

A collection of logic puzzles for Android and iOS.
Every puzzle has exactly one answer, which you can always reach by logic without guessing.

Puzzles: Binairo (also called Takuzu). More are planned.

## Layout

- `packages/<puzzle>_core/`: one pure Dart package for each puzzle, with its rules, solver and generator. No Flutter, so each core is easy to port.
  - `packages/binairo_core/`: Binairo.
- `app/`: the Flutter app, `puzzlery_app`. It uses the core packages.

All are members of one [Dart pub workspace](https://dart.dev/tools/pub/workspaces) (root `pubspec.yaml`).

## How Binairo puzzles are made

1. Fill a random full board with backtracking search.
2. Remove clues one by one in random order.
3. Keep a clue removed only if the logical solver can still finish the board using the deductions allowed by the level.

Every deduction is forced, so a board the solver finishes has exactly one solution.
Easy uses pairs, gaps and line counts. Hard adds line lookahead and duplicate-line elimination, and must need them.

## Commands

```shell
flutter pub get

# Core
cd packages/binairo_core
dart test --exclude-tags slow   # fast tests
dart test --tags slow           # 1600 generated puzzles checked for uniqueness
dart run binairo_core:generate_puzzle --size 10 --difficulty hard --seed 42

# App
cd app
flutter test
flutter run --release           # phone plugged in with USB debugging on
flutter build apk --release     # build/app/outputs/flutter-apk/app-release.apk
```
