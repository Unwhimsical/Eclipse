// Profile MITM fields: model coverage.
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_clash/models/profile.dart';

Profile _makeProfile() {
  return Profile(id: 1, autoUpdateDuration: const Duration(hours: 24));
}

void main() {
  group('Profile MITM fields', () {
    test('defaults are disabled and empty', () {
      final p = _makeProfile();
      expect(p.mitmEnabled, isFalse);
      expect(p.mitmHostnames, isEmpty);
    });

    test('copyWith preserves MITM fields', () {
      final p = _makeProfile().copyWith(
        mitmEnabled: true,
        mitmHostnames: ['gs-loc.apple.com'],
      );
      expect(p.mitmEnabled, isTrue);
      expect(p.mitmHostnames, ['gs-loc.apple.com']);
    });

    test('equality includes MITM fields', () {
      final a = _makeProfile().copyWith(mitmEnabled: true);
      final b = _makeProfile().copyWith(mitmEnabled: false);
      expect(a == b, isFalse);
      final c = _makeProfile().copyWith(mitmHostnames: ['a.com']);
      final d = _makeProfile().copyWith(mitmHostnames: ['b.com']);
      expect(c == d, isFalse);
    });

    test('JSON round-trip preserves MITM fields', () {
      final p = _makeProfile().copyWith(
        mitmEnabled: true,
        mitmHostnames: ['gs-loc.apple.com', 'gsp-ssl.ls.apple.com'],
      );
      final json = p.toJson();
      final restored = Profile.fromJson(json);
      expect(restored.mitmEnabled, isTrue);
      expect(restored.mitmHostnames, [
        'gs-loc.apple.com',
        'gsp-ssl.ls.apple.com',
      ]);
    });
  });
}
