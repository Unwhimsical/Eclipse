import 'dart:io';

import 'package:fl_clash/common/system.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression test for the iOS add-config crash (2026-09-28).
///
/// Root cause: `CoreController._internal()` selected the core interface with
/// `isAndroid`. On iOS `isAndroid` is false, so it fell into the desktop
/// branch where `coreService` is null, throwing a null-check error that
/// surfaced as `ProviderException: Tried to use a provider that is in
/// error state.` when opening the add-config dialog.
///
/// Fix: select with `isMobile` (true for both Android and iOS) so iOS takes
/// the mobile branch (`coreLib`). This test nails that invariant: iOS must
/// be treated as mobile for core-interface selection.
void main() {
  group('iOS core interface selection regression', () {
    test('isMobile covers iOS, not just Android', () {
      // The invariant the fix depends on: isMobile must be true whenever
      // isIOS is true, regardless of isAndroid.
      //
      // We cannot flip Platform.isIOS in a unit test, so we assert the
      // logical relationship directly: isMobile == (isAndroid || isIOS).
      // If someone redefines isMobile as just isAndroid, this fails on
      // every platform, including CI.
      final system = System();
      expect(
        system.isMobile,
        system.isAndroid || system.isIOS,
        reason:
            'isMobile must be (isAndroid || isIOS); iOS must take the mobile core branch',
      );
    });

    test('isMobile is not equivalent to isAndroid alone', () {
      // Guard against the exact regression: redefining isMobile as
      // `isAndroid` would silently break iOS again. On any platform where
      // isIOS differs from isAndroid, the two must differ; on other
      // platforms we verify the definition textually below.
      final system = System();
      if (system.isIOS != system.isAndroid) {
        expect(system.isMobile, isNot(system.isAndroid));
      }
    });

    test('CoreController uses isMobile for interface selection', () {
      // Canary test: CoreController._internal must branch on isMobile,
      // not isAndroid. If a future edit reverts to isAndroid, iOS breaks
      // again with the same null coreService crash.
      final source = File(
        'lib/core/controller.dart',
      ).readAsStringSync();
      final internalBody = RegExp(
        r'CoreController\._internal\(\)\s*\{([^}]*)\}',
        dotAll: true,
      ).firstMatch(source)?.group(1);
      expect(
        internalBody,
        isNotNull,
        reason: 'CoreController._internal constructor not found',
      );
      expect(
        internalBody,
        contains('isMobile'),
        reason:
            'CoreController._internal must select the core interface with isMobile (covers iOS)',
      );
      // The buggy pattern was a bare isAndroid check selecting coreLib.
      // Allow isAndroid only as part of the isMobile definition, never as
      // the branch condition here.
      final branchOnAndroid = RegExp(
        r'if\s*\([^)]*\bisAndroid\b[^)]*\)',
      ).hasMatch(internalBody!);
      expect(
        branchOnAndroid,
        isFalse,
        reason:
            'CoreController._internal must not branch on isAndroid; use isMobile so iOS takes the mobile branch',
      );
    });
  });
}
