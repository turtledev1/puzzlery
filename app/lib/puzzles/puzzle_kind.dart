import 'package:flutter/painting.dart';

enum PuzzleKind {
  binairo(seedColor: Color(0xFF3D7DD8));

  const PuzzleKind({required this.seedColor});

  final Color seedColor;
}
