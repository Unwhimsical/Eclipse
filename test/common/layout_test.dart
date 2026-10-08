import 'package:fl_clash/common/layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('desktop window geometry', () {
    test('minimum window covers the desktop layout breakpoint', () {
      expect(kMinDesktopWindowSize.width, 1160);
      expect(kMinDesktopWindowSize.height, 720);
      expect(kMinDesktopWindowSize.width, greaterThanOrEqualTo(840));
    });

    test('window header heights follow the platform rule', () {
      expect(getWindowHeaderHeight(isDesktop: true, isMacOS: false), 32);
      expect(getWindowHeaderHeight(isDesktop: true, isMacOS: true), 28);
      expect(getWindowHeaderHeight(isDesktop: false, isMacOS: false), 0);
    });
  });
}
