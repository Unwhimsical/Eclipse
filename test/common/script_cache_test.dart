import 'dart:io';

import 'package:fl_clash/common/script_cache.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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
  TestWidgetsFlutterBinding.ensureInitialized();

  // AppPath is a process-wide singleton: its data dir latches to the first
  // path provider seen, so the whole file shares one temp root.
  late Directory root;
  final cache = ScriptCache();

  String cacheDir() => p.join(root.path, 'modules', 'script_cache');

  setUpAll(() async {
    root = await Directory.systemTemp.createTemp('script_cache_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() async {
    if (await root.exists()) await root.delete(recursive: true);
  });

  tearDown(() => cache.clear());

  group('ScriptCache', () {
    test('put then get returns the body', () async {
      await cache.put('https://example.com/a.js', 'console.log(1);');
      expect(await cache.get('https://example.com/a.js'), 'console.log(1);');
    });

    test('get misses on unknown url', () async {
      expect(await cache.get('https://example.com/nope.js'), isNull);
      expect(await cache.getStale('https://example.com/nope.js'), isNull);
    });

    test('different urls do not collide', () async {
      await cache.put('https://example.com/a.js', 'aaa');
      await cache.put('https://example.com/b.js', 'bbb');
      expect(await cache.get('https://example.com/a.js'), 'aaa');
      expect(await cache.get('https://example.com/b.js'), 'bbb');
    });

    test('expired entry: get misses, getStale hits', () async {
      await cache.put('https://example.com/old.js', 'stale-body');
      final file = Directory(
        cacheDir(),
      ).listSync().whereType<File>().firstWhere((f) => f.path.endsWith('.js'));
      await file.setLastModified(
        DateTime.now().subtract(const Duration(hours: 25)),
      );
      expect(await cache.get('https://example.com/old.js'), isNull);
      expect(await cache.getStale('https://example.com/old.js'), 'stale-body');
    });

    test('put ignores empty content', () async {
      await cache.put('https://example.com/e.js', '');
      expect(await cache.get('https://example.com/e.js'), isNull);
    });

    test('clear removes all entries', () async {
      await cache.put('https://example.com/a.js', 'aaa');
      await cache.put('https://example.com/b.js', 'bbb');
      await cache.clear();
      expect(await cache.get('https://example.com/a.js'), isNull);
      expect(await cache.getStale('https://example.com/b.js'), isNull);
    });

    test('entries are capped at maxEntries, oldest evicted', () async {
      for (var i = 0; i < ScriptCache.maxEntries + 5; i++) {
        await cache.put('https://example.com/$i.js', 'body-$i');
        // Distinct mtimes keep the eviction order deterministic.
        await Future<void>.delayed(const Duration(milliseconds: 2));
      }
      final count = Directory(cacheDir()).listSync().whereType<File>().length;
      expect(count, ScriptCache.maxEntries);
      // The oldest entries were evicted.
      expect(await cache.getStale('https://example.com/0.js'), isNull);
      expect(
        await cache.getStale(
          'https://example.com/${ScriptCache.maxEntries + 4}.js',
        ),
        isNotNull,
      );
    });
  });
}
