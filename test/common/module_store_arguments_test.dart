import 'dart:io';

import 'package:fl_clash/common/module_store.dart';
import 'package:fl_clash/common/path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late Directory tmp;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('modargs');
    PathProviderPlatform.instance = _FakePathProvider(tmp.path);
    // Trigger AppPath init once so homeDirPath resolves to the temp dir.
    await appPath.homeDirPath;
  });

  tearDownAll(() async {
    await tmp.delete(recursive: true);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ModuleStore argument values', () {
    test('import stores empty argument values', () async {
      final info = await moduleStore.import(
        '#!name=M\n#!arguments=a:1\n[Rule]\nDOMAIN,a.com,REJECT\n',
      );
      expect(info.argumentValues, isEmpty);
      expect((await moduleStore.list()).single.argumentValues, isEmpty);
    });

    test('setArgumentValues persists', () async {
      final info = await moduleStore.import(
        '#!name=M\n#!arguments=a:1\n[Rule]\nDOMAIN,a.com,REJECT\n',
      );
      await moduleStore.setArgumentValues(info.id, {'a': '2'});
      expect((await moduleStore.list()).single.argumentValues, {'a': '2'});
    });

    test('updateContent keeps user values for surviving keys', () async {
      final info = await moduleStore.import(
        '#!name=M\n#!arguments=a:1, b:2\n[Rule]\nDOMAIN,a.com,REJECT\n',
      );
      await moduleStore.setArgumentValues(info.id, {'a': 'user', 'b': 'userb'});
      final updated = await moduleStore.updateContent(
        info.id,
        '#!name=M\n#!arguments=a:10, c:30\n[Rule]\nDOMAIN,b.com,REJECT\n',
      );
      expect(updated, isNotNull);
      expect(updated!.argumentValues, {'a': 'user'});
      final raw = await moduleStore.readRaw(info.id);
      expect(raw, contains('DOMAIN,b.com,REJECT'));
      expect(updated.ruleCount, 1);
    });

    test('updateContent returns null for unknown id', () async {
      expect(await moduleStore.updateContent('nope', '#!name=X\n'), isNull);
    });

    test('updateContent rewrites rule providers with new values', () async {
      final rules = List.generate(
        2001,
        (i) => 'DOMAIN-SUFFIX,{{{h}}}$i.com,REJECT',
      ).join('\n');
      final info = await moduleStore.import(
        '#!name=Big\n#!arguments=h:base\n[Rule]\n$rules\n',
      );
      expect(info.ruleSetRules, isNotEmpty);
      await moduleStore.setArgumentValues(info.id, {'h': 'custom'});
      final updated = await moduleStore.updateContent(
        info.id,
        '#!name=Big\n#!arguments=h:base\n[Rule]\n$rules\n',
      );
      expect(updated, isNotNull);
      expect(updated!.argumentValues, {'h': 'custom'});
      final providerFile = File(
        await moduleStore.ruleProviderPath(info.id, 'REJECT'),
      );
      expect(await providerFile.exists(), isTrue);
      expect(await providerFile.readAsString(), contains('+.custom0.com'));
    });
  });
}
