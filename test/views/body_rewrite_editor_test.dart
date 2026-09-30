import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/rewrite/body_rewrite_editor.dart';
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

  setUp(() {
    setupAction = _RecordingSetupAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([
            Profile.normal(label: 'p').copyWith(
              id: profileId,
              bodyRewrites: [
                'http-response ^https://example.com/api "ad":true "ad":false',
              ],
            ),
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
        child: const TestApp(
          child: BodyRewriteEditorPage(profileId: profileId),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  List<String> currentLines() => container
      .read(profilesProvider)
      .firstWhere((p) => p.id == profileId)
      .bodyRewrites;

  testWidgets('renders existing entries', (tester) async {
    await pumpPage(tester);
    expect(find.text('^https://example.com/api'), findsOneWidget);
    expect(find.text('http-response'), findsOneWidget);
  });

  testWidgets('add regex entry persists and re-applies', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '^https://x.com/b');
    await tester.enterText(fields.at(1), '"vip":0');
    await tester.enterText(fields.at(2), '"vip":1');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(currentLines(), [
      'http-response ^https://example.com/api "ad":true "ad":false',
      'http-request ^https://x.com/b "vip":0 "vip":1',
    ]);
    expect(setupAction.applyCalls, 1);
  });

  testWidgets('jq type shows the jq field instead of regex fields', (
    tester,
  ) async {
    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('http-response-jq').last);
    await tester.pumpAndSettle();
    expect(find.text('jq 表达式'), findsOneWidget);
    expect(find.text('正则'), findsNothing);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '^https://x.com/j');
    await tester.enterText(fields.at(1), 'del(.data.ad)');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(
      currentLines().last,
      'http-response-jq ^https://x.com/j del(.data.ad)',
    );
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

  test('serialize mirrors the parse format', () {
    expect(
      serializeBodyRewriteRule(
        type: 'http-request',
        pattern: '^https://x.com/a',
        regex: 'a',
        replacement: 'b',
      ),
      'http-request ^https://x.com/a a b',
    );
    expect(
      serializeBodyRewriteRule(
        type: 'http-response-jq',
        pattern: '^https://x.com/a',
        jq: 'del(.x)',
      ),
      'http-response-jq ^https://x.com/a del(.x)',
    );
    final parsed = parseBodyRewriteLine(
      'http-response-jq ^https://x.com/a del(.x)',
    );
    expect(parsed?.type, 'http-response-jq');
    expect(parsed?.jq, 'del(.x)');
  });
}
