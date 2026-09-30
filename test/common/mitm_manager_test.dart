import 'dart:io';

import 'package:fl_clash/common/ca_store.dart';
import 'package:fl_clash/common/mitm_manager.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MitmManager.parseScriptLine', () {
    test('parses full script line', () {
      final parsed = MitmManager.parseScriptLine(
        'test.js = type=http-response,pattern=^https://example.com,'
        'requires-body=1,binary-body-mode=1,timeout=30,'
        'max-size=1048576,argument=hello,'
        'script-path=https://example.com/test.js',
      );
      expect(parsed, isNotNull);
      expect(parsed!['name'], 'test.js');
      expect(parsed['type'], 'http-response');
      expect(parsed['pattern'], '^https://example.com');
      expect(parsed['requiresBody'], isTrue);
      expect(parsed['binaryBody'], isTrue);
      expect(parsed['timeout'], 30);
      expect(parsed['maxSize'], 1048576);
      expect(parsed['argument'], 'hello');
      expect(parsed['scriptPath'], 'https://example.com/test.js');
    });

    test('uses defaults for missing fields', () {
      final parsed = MitmManager.parseScriptLine(
        'simple.js = type=http-request,pattern=.*',
      );
      expect(parsed, isNotNull);
      expect(parsed!['name'], 'simple.js');
      expect(parsed['type'], 'http-request');
      expect(parsed['requiresBody'], isFalse);
      expect(parsed['binaryBody'], isFalse);
      expect(parsed['timeout'], 20);
      expect(parsed['maxSize'], 10 * 1024 * 1024);
      expect(parsed['argument'], '');
      expect(parsed['scriptPath'], isNull);
    });

    test('parses boolean variants', () {
      final yes = MitmManager.parseScriptLine(
        'a.js = type=http-response,requires-body=yes',
      );
      expect(yes!['requiresBody'], isTrue);
      final t = MitmManager.parseScriptLine(
        'b.js = type=http-response,requires-body=true',
      );
      expect(t!['requiresBody'], isTrue);
      final no = MitmManager.parseScriptLine(
        'c.js = type=http-response,requires-body=0',
      );
      expect(no!['requiresBody'], isFalse);
    });

    test('falls back on invalid numbers', () {
      final parsed = MitmManager.parseScriptLine(
        'a.js = type=http-response,timeout=abc,max-size=xyz',
      );
      expect(parsed!['timeout'], 20);
      expect(parsed['maxSize'], 10 * 1024 * 1024);
    });

    test('returns null without equals sign', () {
      expect(MitmManager.parseScriptLine('no equals here'), isNull);
    });

    test('skips malformed kv parts', () {
      final parsed = MitmManager.parseScriptLine(
        'a.js = type=http-response,brokenpart,pattern=.*',
      );
      expect(parsed, isNotNull);
      expect(parsed!['type'], 'http-response');
      expect(parsed['pattern'], '.*');
    });

    test('exposes listen address and proxy name', () {
      expect(MitmManager.listenAddr, isNotEmpty);
      expect(MitmManager.proxyName, isNotEmpty);
    });
  });

  group('CaMeta', () {
    test('round-trips through json', () {
      final now = DateTime.now();
      final meta = CaMeta(
        createdAt: now,
        expiresAt: now.add(const Duration(days: 3650)),
        sha256: 'abc123',
      );
      final json = meta.toJson();
      final restored = CaMeta.fromJson(json);
      expect(restored.sha256, 'abc123');
      expect(
        restored.createdAt.millisecondsSinceEpoch,
        now.millisecondsSinceEpoch,
      );
      expect(
        restored.expiresAt.millisecondsSinceEpoch,
        now.add(const Duration(days: 3650)).millisecondsSinceEpoch,
      );
    });

    test('tolerates missing fields', () {
      final meta = CaMeta.fromJson({});
      expect(meta.sha256, '');
      expect(meta.expiresAt.isAfter(meta.createdAt), isTrue);
    });

    test('tolerates invalid dates', () {
      final meta = CaMeta.fromJson({
        'createdAt': 'not-a-date',
        'expiresAt': 'also-bad',
        'sha256': 'x',
      });
      expect(meta.sha256, 'x');
    });
  });

  group('MitmManager.syncAndStart profile hostnames', () {
    late Directory root;

    setUpAll(() async {
      root = await Directory.systemTemp.createTemp('mitm_manager_test');
      PathProviderPlatform.instance = _FakePathProvider(root.path);
      SharedPreferences.setMockInitialValues({});
      registerFallbackValue(<String, dynamic>{});
      final caDir = await Directory(p.join(root.path, 'ca')).create();
      await File(p.join(caDir.path, 'ca.crt')).writeAsString('cert');
      await File(p.join(caDir.path, 'ca.key')).writeAsString('key');
    });

    tearDownAll(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    _MockCoreHandlerInterface mockHandler() {
      final handler = _MockCoreHandlerInterface();
      when(() => handler.mitmStop()).thenAnswer((_) async => {});
      return handler;
    }

    test('starts with profile MITM hostnames and no modules', () async {
      final handler = mockHandler();
      Map<String, dynamic>? startedConfig;
      when(() => handler.mitmStart(any())).thenAnswer((invocation) async {
        startedConfig = Map<String, dynamic>.from(
          invocation.positionalArguments.first as Map,
        );
        return <String, dynamic>{};
      });
      final manager = MitmManager(CoreController.scoped(handler));

      final started = await manager.syncAndStart(
        profileMitmHostnames: const ['gs-loc.apple.com', 'example.com'],
      );

      expect(started, isTrue);
      expect(startedConfig, isNotNull);
      expect((startedConfig!['hosts'] as List).toSet(), {
        'gs-loc.apple.com',
        'example.com',
      });
    });

    test('stops when nothing needs MITM', () async {
      final handler = mockHandler();
      final manager = MitmManager(CoreController.scoped(handler));

      final started = await manager.syncAndStart();

      expect(started, isFalse);
      verify(() => handler.mitmStop()).called(1);
    });
  });
}
