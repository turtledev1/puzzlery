import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> messageKeysIn(String arbFileName) {
  final arbContent =
      jsonDecode(File('lib/l10n/$arbFileName').readAsStringSync())
          as Map<String, dynamic>;
  return arbContent.keys.where((key) => !key.startsWith('@')).toSet();
}

void main() {
  test('the French file translates every English text and adds no extra', () {
    expect(messageKeysIn('app_fr.arb'), messageKeysIn('app_en.arb'));
  });
}
