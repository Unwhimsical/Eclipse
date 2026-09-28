import 'dart:typed_data';

import 'package:fl_clash/common/converter.dart';
import 'package:fl_clash/common/num.dart';
import 'package:fl_clash/common/string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  group('string extensions', () {
    test('generateRandomSecret produces requested length', () {
      final secret = generateRandomSecret(16);
      expect(secret, hasLength(16));
      expect(
        RegExp(r'^[a-zA-Z0-9]+$').hasMatch(secret),
        isTrue,
      );
    });

    test('safeSubstring clamps bounds', () {
      expect('hello'.safeSubstring(1, 3), 'el');
      expect('hello'.safeSubstring(10), '');
      expect('hello'.safeSubstring(-5, 2), 'he');
      expect(''.safeSubstring(0, 5), '');
    });

    test('compareToLower ignores case', () {
      expect('ABC'.compareToLower('abc'), 0);
      expect('a'.compareToLower('B'), lessThan(0));
    });

    test('splitByMultipleSeparators splits on mixed separators', () {
      expect('a,b;c d'.splitByMultipleSeparators, ['a', 'b', 'c', 'd']);
      expect('single'.splitByMultipleSeparators, 'single');
    });
  });

  group('num extensions', () {
    test('OffsetExt axis offsets', () {
      const offset = Offset(3, 4);
      expect(offset.getCrossAxisOffset(Axis.vertical), 3);
      expect(offset.getCrossAxisOffset(Axis.horizontal), 4);
      expect(offset.getMainAxisOffset(Axis.vertical), 4);
      expect(offset.getMainAxisOffset(Axis.horizontal), 3);
    });

    test('traffic formats bytes', () {
      final show = 2048.traffic;
      expect(show.unit, 'KB');
    });
  });

  group('converter', () {
    test('Uint8ListToListIntConverter converts', () {
      final converter = Uint8ListToListIntConverter();
      expect(converter.convert(Uint8List.fromList([1, 2, 3])), [1, 2, 3]);
    });
  });
}
