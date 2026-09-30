import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/proxy_chain/proxy_chain_editor.dart';
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
  const proxies = [
    Proxy(name: 'A', type: 'ss'),
    Proxy(name: 'B', type: 'vmess'),
    Proxy(name: 'C', type: 'trojan'),
  ];
  late ProviderContainer container;
  late _RecordingSetupAction setupAction;

  Profile profileWith(Map<String, String> proxyChains) => Profile.normal(
    label: 'p',
  ).copyWith(id: profileId, proxyChains: proxyChains);

  setUp(() {
    setupAction = _RecordingSetupAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([profileWith(const {})]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => profileId),
        setupActionProvider.overrideWith(() => setupAction),
        clashConfigProvider(
          profileId,
        ).overrideWith((ref) async => const ClashConfig(proxies: proxies)),
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
        child: const TestApp(child: ProxyChainEditorPage(profileId: profileId)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Map<String, String> currentChains() => container
      .read(profilesProvider)
      .firstWhere((p) => p.id == profileId)
      .proxyChains;

  testWidgets('renders proxies with direct state', (tester) async {
    await pumpPage(tester);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.textContaining('直连出站'), findsNWidgets(3));
  });

  testWidgets('picking a via persists and previews the chain', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('直连').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('B').last);
    await tester.pumpAndSettle();

    expect(currentChains(), {'A': 'B'});
    expect(find.textContaining('链路：A → B → 落地'), findsOneWidget);
    expect(setupAction.applyCalls, 1);
  });

  testWidgets('a looped pick is rejected and keeps the old chains', (
    tester,
  ) async {
    container
        .read(profilesProvider.notifier)
        .updateProfile(profileId, (p) => p.copyWith(proxyChains: {'A': 'B'}));
    await pumpPage(tester);

    await tester.tap(find.text('直连').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('A').last);
    await tester.pumpAndSettle();

    expect(currentChains(), {'A': 'B'});
    expect(setupAction.applyCalls, 0);
  });

  testWidgets('stale entries are cleaned when the page opens', (tester) async {
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (p) => p.copyWith(
            proxyChains: {'A': 'B', 'Ghost': 'A', 'B': 'Vanished'},
          ),
        );
    await pumpPage(tester);
    await tester.pumpAndSettle();

    expect(currentChains(), {'A': 'B'});
  });
}
