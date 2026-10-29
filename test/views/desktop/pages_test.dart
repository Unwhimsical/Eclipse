import 'dart:async';

import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _FakeCoreController extends Mock implements CoreController {}

class _TestCustomRules extends ProfileCustomRules {
  _TestCustomRules(this.initial);

  final List<Rule> initial;

  @override
  Stream<List<Rule>> build(int profileId) => Stream.value(initial);
}

ThemeData _desktopTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark().eclipseDesktop,
  ).withDesktopTheme(Brightness.dark);
}

Future<void> _pumpPage(
  WidgetTester tester,
  Widget page, {
  List<Override> overrides = const [],
}) {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  return tester.pumpWidget(
    TestApp(
      overrides: overrides,
      homeBuilder: (child) => Theme(
        data: _desktopTheme(),
        child: Scaffold(body: child),
      ),
      child: page,
    ),
  );
}

List<Override> _baseOverrides() {
  return [
    isStartProvider.overrideWithValue(false),

    currentGroupsStateProvider.overrideWithValue(const GroupsState(value: [])),
    profilesProvider.overrideWith(() => TestProfiles(const [])),
    currentProfileIdProvider.overrideWithBuild((_, _) => null),
  ];
}

void main() {
  group('desktop pages smoke', () {
    testWidgets('home page builds', (tester) async {
      await _pumpPage(
        tester,
        const DesktopHomeView(),
        overrides: _baseOverrides(),
      );
      await tester.pump();
      expect(find.byType(DesktopHomeView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('config page builds with empty profiles', (tester) async {
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: _baseOverrides(),
      );
      await tester.pump();
      expect(find.byType(DesktopConfigView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('modules page builds', (tester) async {
      await _pumpPage(
        tester,
        const DesktopModulesView(),
        overrides: _baseOverrides(),
      );
      await tester.pump();
      expect(find.byType(DesktopModulesView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('data page builds', (tester) async {
      final core = _FakeCoreController();
      when(() => core.getConnections()).thenAnswer((_) async => []);
      await _pumpPage(
        tester,
        const DesktopDataView(),
        overrides: [
          ..._baseOverrides(),
          coreHandlerProvider.overrideWithValue(core),
        ],
      );
      await tester.pump();
      expect(find.byType(DesktopDataView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings page builds', (tester) async {
      await _pumpPage(
        tester,
        const DesktopSettingsView(),
        overrides: _baseOverrides(),
      );
      await tester.pump();
      expect(find.byType(DesktopSettingsView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('config page shows profile list with rules toolbar', (
      tester,
    ) async {
      final profile = Profile.normal(label: 'Test profile');
      final other = Profile.normal(label: 'Other profile');
      final rules = [
        const Rule(
          id: 1,
          content: 'example.com',
          ruleTarget: 'REJECT',
          order: 'a0',
        ),
        const Rule(
          id: 2,
          content: 'proxy.example.com',
          ruleTarget: 'DIRECT',
          order: 'a1',
        ),
      ];
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile, other])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestCustomRules(rules),
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(DesktopConfigView), findsOneWidget);
      expect(find.text('Test profile'), findsWidgets);
      expect(find.text('Other profile'), findsOneWidget);
      expect(find.text('In use'), findsWidgets);
      expect(find.text('Rules'), findsOneWidget);
      expect(find.text('Modules'), findsOneWidget);
      expect(find.text('Proxy group'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('DNS'), findsOneWidget);
      expect(find.text('Test Rules'), findsOneWidget);
      expect(find.text('Add rule'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
      expect(find.text('proxy.example.com'), findsOneWidget);
      expect(find.text('REJECT'), findsOneWidget);
      expect(find.text('DIRECT'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('config page nodes tab shows dashboard and rich node card', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final profile = Profile.normal(label: 'Test profile');
      final groups = [
        Group(
          type: GroupType.Selector,
          name: 'PROXY',
          now: 'Node A',
          all: const [
            Proxy(name: 'Node A', type: 'vmess'),
            Proxy(name: 'Node B', type: 'trojan'),
          ],
        ),
      ];
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          currentGroupsStateProvider.overrideWithValue(
            GroupsState(value: groups),
          ),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestCustomRules(const []),
          ),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nodes'));
      await tester.pumpAndSettle();
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Current node'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);
      expect(find.text('Download'), findsOneWidget);
      expect(find.text('PROXY'), findsOneWidget);
      expect(find.text('Node A'), findsWidgets);
      expect(find.text('Node B'), findsOneWidget);
      expect(find.text('VMESS'), findsOneWidget);
      expect(find.text('TROJAN'), findsOneWidget);
      expect(find.text('Delay test'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('proxies page builds with empty groups', (tester) async {
      await _pumpPage(
        tester,
        const DesktopProxiesView(),
        overrides: _baseOverrides(),
      );
      await tester.pump();
      expect(find.byType(DesktopProxiesView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('proxies page lists groups and nodes', (tester) async {
      final groups = [
        Group(
          type: GroupType.Selector,
          name: 'PROXY',
          now: 'Node A',
          all: const [
            Proxy(name: 'Node A', type: 'vmess'),
            Proxy(name: 'Node B', type: 'trojan'),
          ],
        ),
      ];
      await _pumpPage(
        tester,
        const DesktopProxiesView(),
        overrides: [
          isStartProvider.overrideWithValue(false),
          profilesProvider.overrideWith(() => TestProfiles(const [])),
          currentProfileIdProvider.overrideWithBuild((_, _) => null),
          currentGroupsStateProvider.overrideWithValue(
            GroupsState(value: groups),
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('PROXY'), findsOneWidget);
      expect(find.text('Node A'), findsOneWidget);
      expect(find.text('Node B'), findsOneWidget);
      expect(find.text('vmess'), findsOneWidget);
      expect(find.text('trojan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('config page switches profile and placeholder tabs', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final profile = Profile.normal(label: 'Test profile');
      final other = Profile.normal(label: 'Other profile');
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile, other])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestCustomRules(const []),
          ),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other profile'));
      await tester.pumpAndSettle();
      expect(find.text('Other profile'), findsWidgets);
      await tester.tap(find.text('Modules'));
      await tester.pumpAndSettle();
      expect(find.text('Coming soon'), findsNothing);
      await tester.tap(find.text('DNS'));
      await tester.pumpAndSettle();
      expect(find.text('Coming soon'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
