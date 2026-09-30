import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/modules/module_argument_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
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

  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('modarg_editor');
    PathProviderPlatform.instance = _FakePathProvider(tmp.path);
    await appPath.homeDirPath;
  });

  tearDownAll(() async {
    await tmp.delete(recursive: true);
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// Real file IO only completes outside the fake-async zone.
  Future<T> runIo<T>(WidgetTester tester, Future<T> Function() fn) async {
    return (await tester.runAsync(fn)) as T;
  }

  Future<Future<bool?>> pumpAndOpenEditor(
    WidgetTester tester,
    ModuleInfo info,
  ) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    recorder = _RuleRecorder();
    final coreHandler = _MockCoreHandlerInterface();
    when(
      () => coreHandler.mitmStop(),
    ).thenAnswer((_) async => <String, dynamic>{});
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
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1000));
    globalState.container = container;

    final raw = await runIo(tester, () => moduleStore.readRaw(info.id)) ?? '';
    final declared = parseSgmodule(raw);
    final completer = Completer<bool?>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: TextButton(
              onPressed: () async {
                completer.complete(
                  await dialogs.showCommonDialog<bool>(
                    child: ModuleArgumentEditorDialog(
                      info: info,
                      arguments: declared.arguments,
                      descriptions: declared.argumentDescriptions,
                    ),
                  ),
                );
              },
              child: const Text('open editor'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open editor'));
    await tester.pumpAndSettle();
    return completer.future;
  }

  testWidgets('renders fields with defaults and saves new values', (
    tester,
  ) async {
    const raw =
        '#!name=EdMod\n'
        '#!arguments=host:one.com,port:8080\n'
        '#!arguments-desc=host:Target host\\nport:Target port\n'
        '[Rule]\n'
        'DOMAIN-SUFFIX,{{{host}}},REJECT\n';
    final info = await runIo(tester, () => moduleStore.import(raw));
    final dialogResult = await pumpAndOpenEditor(tester, info);

    expect(find.text('host'), findsOneWidget);
    expect(find.text('port'), findsOneWidget);
    expect(find.text('Target host'), findsOneWidget);
    final fields = tester
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();
    expect(fields.map((e) => e.controller!.text).toList(), ['one.com', '8080']);

    await tester.enterText(find.byType(TextFormField).first, 'two.com');
    // The submit handler performs real file IO, which only completes in the
    // real async zone: drive the tap inside runAsync, wait for the save to
    // land, then pump back in fake-async so the dialog pop resolves.
    await tester.runAsync(() async {
      await tester.tap(find.text('Submit'));
      final deadline = DateTime.now().add(const Duration(seconds: 30));
      while (DateTime.now().isBefore(deadline)) {
        final saved = await moduleStore.findByName('EdMod');
        if (saved?.argumentValues['host'] == 'two.com') break;
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();
    await tester.pump();
    expect(await dialogResult, true);
    expect(
      (await runIo(
        tester,
        () => moduleStore.findByName('EdMod'),
      ))!.argumentValues,
      {'host': 'two.com', 'port': '8080'},
    );
    expect(recorder.added.map((e) => e.rawValue).toList(), [
      'DOMAIN-SUFFIX,two.com,REJECT',
    ]);
  });
}
