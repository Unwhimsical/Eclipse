import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';
import '../helpers/test_database_providers.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.basePath);

  final String basePath;

  @override
  Future<String?> getTemporaryPath() async => basePath;

  @override
  Future<String?> getApplicationSupportPath() async => basePath;

  @override
  Future<String?> getApplicationCachePath() async => basePath;
}

/// Shared recording state, independent of notifier instances: widget pumps
/// can recreate the provider element, so the override factory must return a
/// fresh notifier every time and state must live outside the notifier.
class _RuleRecorder {
  final added = <Rule>[];
  final deletedIds = <int>[];
  final rules = <Rule>[];
}

class _RecordingGlobalRules extends TestGlobalRules {
  _RecordingGlobalRules(this.recorder) : super(const []);

  final _RuleRecorder recorder;

  @override
  Stream<List<Rule>> build() => Stream.value(List.of(recorder.rules));

  @override
  void put(Rule rule) {
    recorder.added.add(rule);
    recorder.rules.add(rule);
    state = AsyncData(List.of(recorder.rules));
  }

  @override
  void delAll(Iterable<int> ruleIds) {
    recorder.deletedIds.addAll(ruleIds);
    final ids = ruleIds.toSet();
    recorder.rules.removeWhere((item) => ids.contains(item.id));
    state = AsyncData(List.of(recorder.rules));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late ProviderContainer container;
  late _RuleRecorder recorder;
  late _MockCoreHandlerInterface coreHandler;
  late WidgetRef ref;
  Map<String, dynamic>? lastMitmStartConfig;

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('sr_import_args');
    PathProviderPlatform.instance = _FakePathProvider(tmp.path);
    await appPath.homeDirPath;
    registerFallbackValue(<String, dynamic>{});
    final caDir = await Directory(p.join(tmp.path, 'ca')).create();
    await File(p.join(caDir.path, 'ca.crt')).writeAsString('cert');
    await File(p.join(caDir.path, 'ca.key')).writeAsString('key');
  });

  tearDownAll(() async {
    await tmp.delete(recursive: true);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    recorder = _RuleRecorder();
    coreHandler = _MockCoreHandlerInterface();
    when(
      () => coreHandler.mitmStop(),
    ).thenAnswer((_) async => <String, dynamic>{});
    when(
      () => coreHandler.mitmUpdateConfig(any()),
    ).thenAnswer((_) async => {'running': false});
    when(() => coreHandler.mitmStart(any())).thenAnswer((invocation) async {
      lastMitmStartConfig = Map<String, dynamic>.from(
        invocation.positionalArguments.first as Map,
      );
      return <String, dynamic>{};
    });
    lastMitmStartConfig = null;
    container = ProviderContainer(
      overrides: [
        // Fresh notifier per factory call: pumps can recreate the element.
        globalRulesProvider.overrideWith(() => _RecordingGlobalRules(recorder)),
        coreHandlerProvider.overrideWithValue(
          CoreController.scoped(coreHandler),
        ),
        currentProfileProvider.overrideWith((_) => null),
      ],
    );
    addTearDown(container.dispose);
    // globalRulesProvider is autoDispose: keep a listener so reads share one
    // element instead of mounting a fresh notifier per read.
    addTearDown(container.listen(globalRulesProvider, (_, _) {}).close);
    globalState.container = container;
  });

  Future<void> pumpRef(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Consumer(
            builder: (context, r, _) {
              ref = r;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  /// Real file IO only completes outside the fake-async zone.
  Future<T> runIo<T>(WidgetTester tester, Future<T> Function() fn) async {
    return (await tester.runAsync(fn)) as T;
  }

  group('ShadowrocketImport.moduleRulesDiff', () {
    test('computes substituted remove/add', () {
      const raw =
          '#!name=M\n#!arguments=a:1\n[Rule]\nDOMAIN-SUFFIX,{{{a}}}.com,REJECT\n';
      final diff = ShadowrocketImport.moduleRulesDiff(
        oldRaw: raw,
        oldValues: const {'a': '9'},
        newRaw: raw,
        newValues: const {'a': '8'},
      );
      expect(diff.remove, ['DOMAIN-SUFFIX,9.com,REJECT']);
      expect(diff.add, ['DOMAIN-SUFFIX,8.com,REJECT']);
    });

    test('null oldRaw removes nothing', () {
      const raw = '#!name=M\n[Rule]\nDOMAIN-SUFFIX,a.com,REJECT\n';
      final diff = ShadowrocketImport.moduleRulesDiff(
        oldRaw: null,
        oldValues: const {},
        newRaw: raw,
        newValues: const {},
      );
      expect(diff.remove, isEmpty);
      expect(diff.add, ['DOMAIN-SUFFIX,a.com,REJECT']);
    });
  });

  group('module argument values end to end', () {
    testWidgets('setModuleArgumentValues re-applies substituted rules', (
      tester,
    ) async {
      await pumpRef(tester);
      const raw =
          '#!name=ArgMod\n#!arguments=host:one.com\n[Rule]\nDOMAIN-SUFFIX,{{{host}}},REJECT\n';
      final info = await runIo(
        tester,
        () => ShadowrocketImport.importModule(ref, raw: raw),
      );
      expect(info, isNotNull);
      expect(recorder.added.map((e) => e.rawValue).toList(), [
        'DOMAIN-SUFFIX,one.com,REJECT',
      ]);

      recorder.added.clear();
      await runIo(
        tester,
        () => ShadowrocketImport.setModuleArgumentValues(ref, info!, {
          'host': 'two.com',
        }),
      );
      expect(recorder.deletedIds, isNotEmpty);
      expect(recorder.added.map((e) => e.rawValue).toList(), [
        'DOMAIN-SUFFIX,two.com,REJECT',
      ]);
      expect(
        (await runIo(
          tester,
          () => moduleStore.findByName('ArgMod'),
        ))!.argumentValues,
        {'host': 'two.com'},
      );
    });

    testWidgets('re-import with existing name updates and keeps values', (
      tester,
    ) async {
      await pumpRef(tester);
      const v1 =
          '#!name=UpdMod\n#!arguments=a:1\n[Rule]\nDOMAIN-SUFFIX,{{{a}}}.com,REJECT\n';
      final info1 = await runIo(
        tester,
        () => ShadowrocketImport.importModule(ref, raw: v1),
      );
      expect(info1, isNotNull);
      await runIo(
        tester,
        () =>
            ShadowrocketImport.setModuleArgumentValues(ref, info1!, {'a': '9'}),
      );

      recorder.added.clear();
      recorder.deletedIds.clear();
      const v2 =
          '#!name=UpdMod\n#!arguments=a:2,b:5\n[Rule]\nDOMAIN-SUFFIX,{{{a}}}.org,REJECT\n';
      final info2 = await runIo(
        tester,
        () => ShadowrocketImport.importModule(ref, raw: v2),
      );
      expect(info2, isNotNull);
      expect(info2!.id, info1!.id);
      expect(info2.argumentValues, {'a': '9'});
      expect(
        (await runIo(
          tester,
          () => moduleStore.list(),
        )).where((e) => e.name == 'UpdMod'),
        hasLength(1),
      );
      expect(recorder.added.map((e) => e.rawValue).toList(), [
        'DOMAIN-SUFFIX,9.org,REJECT',
      ]);
      expect(recorder.deletedIds, isNotEmpty);
    });

    testWidgets('setModuleEnabled applies substituted rules', (tester) async {
      await pumpRef(tester);
      const raw =
          '#!name=TglMod\n#!arguments=host:one.com\n[Rule]\nDOMAIN-SUFFIX,{{{host}}},REJECT\n';
      final info = await runIo(
        tester,
        () => ShadowrocketImport.importModule(ref, raw: raw),
      );
      expect(info, isNotNull);
      await runIo(
        tester,
        () => ShadowrocketImport.setModuleArgumentValues(ref, info!, {
          'host': 'two.com',
        }),
      );

      recorder.added.clear();
      recorder.deletedIds.clear();
      await runIo(
        tester,
        () => ShadowrocketImport.setModuleEnabled(ref, info!, false),
      );
      expect(recorder.deletedIds, isNotEmpty);
      await runIo(
        tester,
        () => ShadowrocketImport.setModuleEnabled(ref, info!, true),
      );
      expect(recorder.added.map((e) => e.rawValue).toList(), [
        'DOMAIN-SUFFIX,two.com,REJECT',
      ]);
    });

    testWidgets('substituted MITM hostnames reach the core', (tester) async {
      await pumpRef(tester);
      const raw =
          '#!name=MitmMod\n#!arguments=host:one.com\n[MITM]\nhostname = {{{host}}}, static.example\n';
      final info = await runIo(
        tester,
        () => ShadowrocketImport.importModule(ref, raw: raw),
      );
      expect(info, isNotNull);
      await runIo(
        tester,
        () => ShadowrocketImport.setModuleArgumentValues(ref, info!, {
          'host': 'two.com',
        }),
      );

      expect(lastMitmStartConfig, isNotNull);
      expect(
        (lastMitmStartConfig!['hosts'] as List).map((e) => '$e').toSet(),
        contains('two.com'),
      );
    });
  });
}
