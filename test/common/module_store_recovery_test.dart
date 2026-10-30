import 'dart:io';

import 'package:fl_clash/common/module_store.dart';
import 'package:fl_clash/common/path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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
  late Directory modulesDir;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('modrecover');
    PathProviderPlatform.instance = _FakePathProvider(tmp.path);
    modulesDir = Directory(p.join(await appPath.homeDirPath, 'modules'));
  });

  tearDownAll(() async {
    await tmp.delete(recursive: true);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    if (await modulesDir.exists()) {
      await for (final entity in modulesDir.list()) {
        await entity.delete(recursive: true);
      }
    }
  });

  Future<void> writeModule(String id, String content) async {
    await modulesDir.create(recursive: true);
    await File(p.join(modulesDir.path, '$id.sgmodule')).writeAsString(content);
  }

  const content = '#!name=Recovered\n[Rule]\nDOMAIN,example.com,REJECT\n';

  test('empty index with a module file on disk recovers the module', () async {
    await writeModule('recovered1', content);
    final modules = await moduleStore.list();
    expect(modules.length, 1);
    expect(modules.single.id, 'recovered1');
    expect(modules.single.name, 'Recovered');
    expect(modules.single.ruleCount, 1);
    expect(modules.single.enabled, isTrue);
    final again = await moduleStore.list();
    expect(again.length, 1);
    expect(again.single.id, 'recovered1');
  });

  test(
    'corrupt index with a module file on disk recovers the module',
    () async {
      await writeModule('recovered2', content);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('eclipse_modules_index', 'not-json');
      final modules = await moduleStore.list();
      expect(modules.length, 1);
      expect(modules.single.id, 'recovered2');
    },
  );

  test('non-empty index wins over orphan files on disk', () async {
    final imported = await moduleStore.import(
      '#!name=Kept\n[Rule]\nDOMAIN,kept.com,REJECT\n',
    );
    await writeModule('orphan1', content);
    final modules = await moduleStore.list();
    expect(modules.map((m) => m.id), [imported.id]);
  });

  test('recovery rebuilds rule-set rules from provider files', () async {
    await writeModule('big1', content);
    await File(
      p.join(modulesDir.path, 'big1_PROXY.yaml'),
    ).writeAsString('payload:\n  - example.com\n');
    final modules = await moduleStore.list();
    expect(modules.single.ruleSetRules, ['RULE-SET,big1_PROXY,PROXY']);
  });

  test('empty index without files stays empty', () async {
    expect(await moduleStore.list(), isEmpty);
  });

  test(
    'recovery falls back to the file id when the module has no name',
    () async {
      await writeModule('noname1', '[Rule]\nDOMAIN,example.com,REJECT\n');
      final modules = await moduleStore.list();
      expect(modules.length, 1);
      expect(modules.single.name, 'noname1');
    },
  );
}
