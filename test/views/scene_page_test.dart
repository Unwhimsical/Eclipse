import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/scene/scene_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  Scene wifiScene(String name, String ssid) => Scene(
    id: 0,
    name: name,
    triggerType: SceneTriggerType.ssid,
    ssid: ssid,
    targetProfileId: 1,
    order: 0,
  );

  setUp(() async {
    database = Database(NativeDatabase.memory());
    addTearDown(database.close);
    await database.scenesDao.put(wifiScene('home', 'MyWifi'));
    container = ProviderContainer(
      overrides: [
        sceneModeEnabledProvider.overrideWithBuild((_, _) => false),
        profilesProvider.overrideWith(
          () => TestProfiles([Profile.normal(label: 'p1').copyWith(id: 1)]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
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
        child: const TestApp(locale: Locale('zh', 'CN'), child: SceneView()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders the master toggle and the scene list', (tester) async {
    await pumpPage(tester);

    expect(find.text('场景模式'), findsWidgets);
    expect(find.text('home'), findsOneWidget);
    expect(find.textContaining('MyWifi'), findsOneWidget);
    expect(container.read(sceneModeEnabledProvider), isFalse);
  });

  testWidgets('toggling the switch enables scene mode', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(container.read(sceneModeEnabledProvider), isTrue);
  });

  testWidgets('adding a scene persists it and shows it in the list', (
    tester,
  ) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('添加场景'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'office');
    await tester.enterText(find.byType(TextField).at(1), 'OfficeWifi');
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(find.text('office'), findsOneWidget);
    expect(find.textContaining('OfficeWifi'), findsOneWidget);
    final stored = await database.scenesDao.queryAll().get();
    expect(stored.map((s) => s.name), contains('office'));
  });

  testWidgets('the save button stays disabled without a name', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('添加场景'));
    await tester.pumpAndSettle();

    final confirmButton = find.widgetWithText(TextButton, '确定');
    expect(tester.widget<TextButton>(confirmButton).onPressed, isNull);
  });

  testWidgets('deleting a scene removes it after confirmation', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.byTooltip('删除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsNothing);
    expect(await database.scenesDao.queryAll().get(), isEmpty);
  });
}
