import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/rewrite/map_local_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingSetupAction extends SetupAction {
  int applyCalls = 0;

  @override
  void applyProfileDebounce({bool silence = false, bool force = false}) {
    applyCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const profileId = 7;
  late ProviderContainer container;
  late _RecordingSetupAction setupAction;

  Profile profileWith(List<String> mapLocal) =>
      Profile.normal(label: 'p').copyWith(id: profileId, mapLocal: mapLocal);

  setUp(() {
    setupAction = _RecordingSetupAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            profileWith([
              '^https://example.com/a data-type=text data=hello status-code=200',
            ]),
          ]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => profileId),
        setupActionProvider.overrideWith(() => setupAction),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
  });

  Future<void> pumpPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container
        .read(viewSizeProvider.notifier)
        .update((_) => const Size(1200, 1000));
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: MapLocalEditorPage(profileId: profileId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> currentLines() => container
      .read(profilesProvider)
      .firstWhere((p) => p.id == profileId)
      .mapLocal;

  testWidgets('renders existing entries', (tester) async {
    await pumpPage(tester);
    expect(find.text('^https://example.com/a'), findsOneWidget);
    expect(find.text('text · 200'), findsOneWidget);
  });

  testWidgets('add entry persists and re-applies the current profile', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '^https://x.com/b');
    await tester.enterText(fields.at(1), 'world');
    await tester.enterText(fields.at(2), '201');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(currentLines(), [
      '^https://example.com/a data-type=text data=hello status-code=200',
      '^https://x.com/b data-type=text data=world status-code=201',
    ]);
    expect(setupAction.applyCalls, 1);
  });

  testWidgets('edit entry keeps headers and updates the line', (tester) async {
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (p) => p.copyWith(
            mapLocal: [
              '^https://h.com/x data-type=text data=old status-code=200 X-Foo=bar',
            ],
          ),
        );
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.edit).first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(1), 'new');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(currentLines(), [
      '^https://h.com/x data-type=text data=new status-code=200 X-Foo=bar',
    ]);
  });

  testWidgets('delete entry asks for confirm', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(currentLines(), isEmpty);
    expect(setupAction.applyCalls, 1);
  });

  test('serialize quotes tokens with whitespace and round-trips', () {
    const line =
        '"^https://x.com/a b" data-type=text data="hi there" status-code=200 X-Foo="bar baz"';
    expect(
      serializeMapLocalRule(
        pattern: '^https://x.com/a b',
        dataType: 'text',
        data: 'hi there',
        statusCode: 200,
        headers: const {'X-Foo': 'bar baz'},
      ),
      line,
    );
    final parsed = parseMapLocalLine(line);
    expect(parsed?.pattern, '^https://x.com/a b');
    expect(parsed?.data, 'hi there');
    expect(parsed?.headers, {'X-Foo': 'bar baz'});
  });
}
