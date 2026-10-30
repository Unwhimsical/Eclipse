import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/components/traffic_chart.dart';
import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class _TestProxyGroups extends ProxyGroups {
  _TestProxyGroups(this.initial);

  final List<ProxyGroup> initial;

  @override
  Stream<List<ProxyGroup>> build(int profileId) => Stream.value(initial);
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

    testWidgets('config page rules toolbar offers per-app entry and filter', (
      tester,
    ) async {
      final profile = Profile.normal(label: 'Test profile');
      final rules = [
        const Rule(
          id: 1,
          content: 'example.com',
          ruleTarget: 'REJECT',
          order: 'a0',
        ),
        const Rule(
          id: 2,
          ruleAction: RuleAction.PROCESS_NAME,
          content: 'chrome.exe',
          ruleTarget: 'PROXY',
          order: 'a1',
        ),
      ];
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          viewSizeProvider.overrideWithValue(const Size(1280, 800)),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestCustomRules(rules),
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Per-app rules'), findsOneWidget);
      expect(find.text('Process'), findsOneWidget);
      expect(find.text('example.com'), findsOneWidget);
      expect(find.text('chrome.exe'), findsOneWidget);
      await tester.tap(find.text('Process'));
      await tester.pumpAndSettle();
      expect(find.text('example.com'), findsNothing);
      expect(find.text('chrome.exe'), findsOneWidget);
      await tester.tap(find.text('Process'));
      await tester.pumpAndSettle();
      expect(find.text('example.com'), findsOneWidget);
      await tester.tap(find.text('Per-app rules'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Route traffic by process name or path, entered manually. On Windows, use the exe name, e.g. chrome.exe.',
        ),
        findsOneWidget,
      );
      expect(find.text('PROCESS-NAME'), findsWidgets);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Rule target'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('config page profile row menu offers update for url profile', (
      tester,
    ) async {
      final subscription = Profile.normal(
        label: 'Sub profile',
        url: 'https://example.com/sub.yaml',
      );
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([subscription])),
          currentProfileIdProvider.overrideWithBuild((_, _) => subscription.id),
          profileCustomRulesProvider.overrideWith2((_) => _TestCustomRules([])),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Sub profile').first,
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      expect(find.text('Update'), findsOneWidget);
      expect(find.text('Set as default'), findsOneWidget);
      expect(find.text('Rename'), findsOneWidget);
      expect(find.text('Duplicate config'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Update'));
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 300));
      }
      expect(find.text('Update'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('config page profile row menu hides update for file profile', (
      tester,
    ) async {
      final local = Profile.normal(label: 'Local profile');
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([local])),
          currentProfileIdProvider.overrideWithBuild((_, _) => local.id),
          profileCustomRulesProvider.overrideWith2((_) => _TestCustomRules([])),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.text('Local profile').first,
        buttons: kSecondaryMouseButton,
      );
      await tester.pumpAndSettle();
      expect(find.text('Update'), findsNothing);
      expect(find.text('Set as default'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
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

    testWidgets('config page switches profile and wired tabs', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final profile = Profile.normal(label: 'Test profile');
      final other = Profile.normal(label: 'Other profile');
      final groups = [
        const ProxyGroup(
          id: 100,
          name: 'Group A',
          type: GroupType.Selector,
          proxies: ['DIRECT'],
        ),
      ];
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile, other])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestCustomRules(const []),
          ),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(groups)),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other profile'));
      await tester.pumpAndSettle();
      expect(find.text('Other profile'), findsWidgets);
      await tester.tap(find.text('Modules'));
      await tester.pumpAndSettle();
      expect(find.text('Coming soon'), findsNothing);
      await tester.tap(find.text('Proxy group'));
      await tester.pumpAndSettle();
      expect(find.text('Group A'), findsOneWidget);
      expect(find.text('Add proxy group'), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);
      await tester.tap(find.text('General'));
      await tester.pumpAndSettle();
      expect(find.text('Port'), findsOneWidget);
      expect(find.text('Allow LAN'), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);
      await tester.tap(find.text('DNS'));
      await tester.pumpAndSettle();
      expect(find.text('Nameserver'), findsOneWidget);
      expect(find.text('Fake-IP range'), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('config page policy group tab opens the edit dialog', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final profile = Profile.normal(label: 'Test profile');
      await _pumpPage(
        tester,
        const DesktopConfigView(),
        overrides: [
          profilesProvider.overrideWith(() => TestProfiles([profile])),
          currentProfileIdProvider.overrideWithBuild((_, _) => profile.id),
          viewSizeProvider.overrideWithValue(const Size(1280, 800)),
          profileCustomRulesProvider.overrideWith2(
            (_) => _TestCustomRules(const []),
          ),
          proxyGroupsProvider.overrideWith2((_) => _TestProxyGroups(const [])),
        ],
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proxy group'));
      await tester.pumpAndSettle();
      expect(find.text('Proxy group is empty'), findsOneWidget);
      await tester.tap(find.text('Add proxy group'));
      await tester.pumpAndSettle();
      expect(find.text('Name'), findsWidgets);
      expect(find.text('Proxy type'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('desktop simple mode', () {
    List<Override> simpleOverrides({bool simpleMode = false}) {
      const groups = [
        Group(
          type: GroupType.Selector,
          name: 'PROXY',
          now: 'Node A',
          all: [
            Proxy(name: 'Node A', type: 'vmess'),
            Proxy(name: 'Node B', type: 'trojan'),
          ],
        ),
      ];
      return [
        isStartProvider.overrideWithValue(false),
        profilesProvider.overrideWith(() => TestProfiles(const [])),
        currentProfileIdProvider.overrideWithBuild((_, _) => null),
        currentGroupsStateProvider.overrideWithValue(
          const GroupsState(value: groups),
        ),
        appSettingProvider.overrideWithBuild(
          (_, _) => AppSettingProps(simpleMode: simpleMode),
        ),
      ];
    }

    testWidgets('home header offers the simple mode toggle', (tester) async {
      await _pumpPage(
        tester,
        const DesktopHomeView(),
        overrides: simpleOverrides(),
      );
      await tester.pump();
      expect(find.text('Simple mode'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('simple view shows node, route and traffic without a chart', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        const DesktopSimpleView(),
        overrides: simpleOverrides(),
      );
      await tester.pump();
      expect(find.text('Node A'), findsOneWidget);
      expect(find.text('Proxy'), findsOneWidget);
      expect(find.text("Today's traffic"), findsOneWidget);
      expect(find.text('Full mode'), findsOneWidget);
      expect(find.text('Auto-select lowest-delay node'), findsOneWidget);
      expect(find.byType(TrafficChart), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('full-mode button switches the preference back off', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        const DesktopSimpleView(),
        overrides: simpleOverrides(simpleMode: true),
      );
      await tester.pump();
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DesktopSimpleView)),
      );
      expect(container.read(appSettingProvider).simpleMode, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings appearance lists simple mode first', (tester) async {
      await _pumpPage(
        tester,
        const DesktopSettingsView(),
        overrides: simpleOverrides(),
      );
      await tester.pump();
      expect(find.text('Simple mode'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Simple mode')).dy,
        lessThan(tester.getTopLeft(find.text('Theme mode')).dy),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('settings shows only the simple mode switch in simple mode', (
      tester,
    ) async {
      await _pumpPage(
        tester,
        const DesktopSettingsView(),
        overrides: simpleOverrides(simpleMode: true),
      );
      await tester.pump();
      expect(find.text('Simple mode'), findsOneWidget);
      expect(find.text('Appearance'), findsNothing);
      expect(find.text('Theme mode'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
