import 'dart:io';

import 'package:fl_clash/views/wifi_upload/wifi_share_server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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
  late Directory tempDir;

  setUpAll(() {
    tempDir = Directory.systemTemp.createTempSync('wifi_share_test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('WifiShareServer serves upload and download roundtrip', () async {
    final server = WifiShareServer();
    await server.start();
    try {
      final port = server.port!;
      final client = HttpClient();
      try {
        final put = await client.postUrl(
          Uri.parse('http://127.0.0.1:$port/upload?name=test.conf'),
        );
        put.write('hello');
        final putRes = await put.close();
        expect(putRes.statusCode, 200);
        await putRes.drain<void>();

        final files = await server.listFiles();
        expect(files.length, 1);

        final get = await client.getUrl(
          Uri.parse('http://127.0.0.1:$port/f/test.conf'),
        );
        final getRes = await get.close();
        expect(getRes.statusCode, 200);
        final body = await getRes
            .transform(const SystemEncoding().decoder)
            .join();
        expect(body, 'hello');

        final bad = await client.postUrl(
          Uri.parse('http://127.0.0.1:$port/upload?name=evil.yaml'),
        );
        final badRes = await bad.close();
        expect(badRes.statusCode, 400);
        await badRes.drain<void>();
      } finally {
        client.close();
      }
    } finally {
      await server.stop();
      server.dispose();
    }
  });
}
