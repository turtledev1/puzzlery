import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SavedGameSummary {
  int get size;
  Enum get difficulty;
  Duration get elapsed;
  DateTime get savedAt;
  double get fillProgress;
}

double fillProgressOf({
  required int cellCount,
  required int givenCellCount,
  required int filledCellCount,
}) {
  final cellsToFill = cellCount - givenCellCount;
  final cellsFilledByPlayer = filledCellCount - givenCellCount;
  return cellsToFill == 0 ? 1 : cellsFilledByPlayer / cellsToFill;
}

abstract class SavedGameRepository<SavedGameType extends SavedGameSummary> {
  const SavedGameRepository();

  @protected
  String get storageKey;

  @protected
  Map<String, Object> encode(SavedGameType savedGame);

  /// Throws [FormatException] or [ArgumentError] when [json] is not a valid
  /// saved game.
  @protected
  SavedGameType decode(Map<String, Object?> json);

  Future<SavedGameType?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final savedText = preferences.getString(storageKey);
    if (savedText == null) {
      return null;
    }
    try {
      final json = jsonDecode(savedText);
      if (json is! Map<String, Object?>) {
        throw const FormatException('A saved game must be a JSON object.');
      }
      return decode(json);
    } on FormatException {
      await clear();
      return null;
    } on ArgumentError {
      await clear();
      return null;
    }
  }

  Future<void> save(SavedGameType savedGame) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, jsonEncode(encode(savedGame)));
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
  }

  static T requireField<T>(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is! T) {
      throw FormatException('Saved game field "$key" is missing or invalid.');
    }
    return value;
  }

  static List<int> requireIntList(Map<String, Object?> json, String key) {
    final values = requireField<List<Object?>>(json, key);
    if (values.any((value) => value is! int)) {
      throw FormatException('Saved game field "$key" must hold integers.');
    }
    return values.cast<int>();
  }
}
