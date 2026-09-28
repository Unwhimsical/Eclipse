import 'package:fl_clash/common/ca_store.dart';
import 'package:fl_clash/common/mitm_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
}
