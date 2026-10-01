import 'dart:io';

import 'package:fl_clash/views/wifi_upload/wifi_share_server.dart';
import 'package:fl_clash/views/wifi_upload/wifi_upload.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import '../helpers/test_app.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  late Directory root;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('wifi_upload_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  test('isShareableName accepts only conf and sgmodule', () {
    expect(isShareableName('a.conf'), isTrue);
    expect(isShareableName('a.sgmodule'), isTrue);
    expect(isShareableName('A.CONF'), isTrue);
    expect(isShareableName('a.yaml'), isFalse);
    expect(isShareableName('../a.conf'), isFalse);
    expect(isShareableName('/etc/a.conf'), isFalse);
    expect(isShareableName('a.conf '), isFalse);
    expect(isShareableName(''), isFalse);
  });

  testWidgets('WifiUploadView renders service switch', (tester) async {
    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: WifiUploadView()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(WifiUploadView), findsOneWidget);
  });
}
