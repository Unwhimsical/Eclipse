import 'dart:io';

import 'package:fl_clash/common/system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS core interface selection', () {
    test('isMobile covers iOS', () {
      final system = System();
      expect(system.isMobile, system.isAndroid || system.isIOS);
    });

    test('CoreController branches on isMobile', () {
      final source = File('lib/core/controller.dart').readAsStringSync();
      final match = RegExp(
        r'CoreController\._internal\(\)\s*\{([^}]*)\}',
        dotAll: true,
      ).firstMatch(source);
      final body = match?.group(1);
      expect(body, isNotNull);
      expect(body, contains('isMobile'));
      final androidPattern = RegExp(r'if\s*\([^)]*\bisAndroid\b[^)]*\)');
      expect(androidPattern.hasMatch(body!), isFalse);
    });
  });
}
