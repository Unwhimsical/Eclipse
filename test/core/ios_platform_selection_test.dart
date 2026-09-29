import 'dart:io';

import 'package:fl_clash/common/system.dart';
import 'package:flutter_test/flutter_test.dart';

// Regression: 2026-09-28 iOS crash, CoreController used isAndroid not isMobile.
void main() {
  group('iOS core interface selection', () {
    test('isMobile covers iOS', () {
      final system = System();
      expect(system.isMobile, system.isAndroid || system.isIOS);
    });

    test('CoreController branches on isMobile, not isAndroid', () {
      final source = File('lib/core/controller.dart').readAsStringSync();
      final body = RegExp(
        r'CoreController\._internal\(\)\s*\{([^}]*)\}',
        dotAll: true,
      ).firstMatch(source)?.group(1);
      expect(body, isNotNull);
      expect(body, contains('isMobile'));
      expect(
        RegExp(r'if\s*\([^)]*\bisAndroid\b[^)]*\)').hasMatch(body!),
        isFalse,
      );
    });
  });
}
