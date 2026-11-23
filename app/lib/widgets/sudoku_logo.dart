import 'package:flutter/material.dart';

import '../puzzles/puzzle_kind.dart';

class SudokuLogo extends StatelessWidget {
  const SudokuLogo({super.key, this.size = 96});

  static const List<String> tileDigits = [
    '1',
    '',
    '3',
    '',
    '5',
    '',
    '7',
    '',
    '9',
  ];

  final double size;

  @override
  Widget build(BuildContext context) {
    final gap = size * 0.05;
    final tileSize = (size - 2 * gap) / 3;
    final filledTileColor = PuzzleKind.sudoku.seedColor;
    final emptyTileColor = filledTileColor.withValues(alpha: 0.3);
    Widget tile(String digit) => Container(
      width: tileSize,
      height: tileSize,
      decoration: BoxDecoration(
        color: digit.isEmpty ? emptyTileColor : filledTileColor,
        borderRadius: BorderRadius.circular(tileSize * 0.2),
      ),
      alignment: Alignment.center,
      child: Text(
        digit,
        style: TextStyle(
          color: Colors.white,
          fontSize: tileSize * 0.6,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var tileRow = 0; tileRow < 3; tileRow++)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var tileColumn = 0; tileColumn < 3; tileColumn++)
                  tile(tileDigits[tileRow * 3 + tileColumn]),
              ],
            ),
        ],
      ),
    );
  }
}
