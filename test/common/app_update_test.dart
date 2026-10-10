import 'package:fl_clash/common/app_update.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('findUpdateAsset', () {
    final assets = [
      {
        'name': 'Eclipse-0.9.1-windows-amd64-setup.exe',
        'browser_download_url': 'https://example.com/win.exe',
        'size': 100,
      },
      {
        'name': 'Eclipse-0.9.1-macos-arm64.dmg',
        'browser_download_url': 'https://example.com/mac.dmg',
        'size': 200,
      },
      {
        'name': 'Eclipse-0.9.1-android-arm64-v8a.apk',
        'browser_download_url': 'https://example.com/app.apk',
        'size': 300,
      },
      {
        'name': 'Eclipse-0.9.1-linux-amd64.AppImage',
        'browser_download_url': 'https://example.com/app.AppImage',
        'size': 400,
      },
      {'name': 'SHA256SUMS', 'browser_download_url': '', 'size': 10},
    ];

    test('returns null for non-matching assets', () {
      final result = findUpdateAsset([
        {'name': 'SHA256SUMS', 'browser_download_url': '', 'size': 1},
      ]);
      expect(result, isNull);
    });

    test('UpdateAsset.fromJson parses fields', () {
      final asset = UpdateAsset.fromJson(assets[0] as Map<String, dynamic>);
      expect(asset.name, 'Eclipse-0.9.1-windows-amd64-setup.exe');
      expect(asset.downloadUrl, 'https://example.com/win.exe');
      expect(asset.size, 100);
    });

    test('UpdateAsset.fromJson handles missing fields', () {
      final asset = UpdateAsset.fromJson({});
      expect(asset.name, '');
      expect(asset.downloadUrl, '');
      expect(asset.size, 0);
    });
  });
}
