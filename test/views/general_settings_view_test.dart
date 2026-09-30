import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/profiles/general.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';
import '../helpers/test_profiles.dart';

class _RecordingSetupAction extends SetupAction {
  int autoApplyCalls = 0;

  @override
  void autoApplyProfile() {
    autoApplyCalls++;
  }
}

ProviderContainer _container(Profile profile, _RecordingSetupAction setup) {
  final container = ProviderContainer(
    overrides: [
      profilesProvider.overrideWith(() => TestProfiles([profile])),
      setupActionProvider.overrideWith(() => setup),
      viewSizeProvider.overrideWithBuild((_, _) => const Size(1400, 1000)),
    ],
  );
  addTearDown(container.dispose);
  globalState.container = container;
  return container;
}

Future<void> _pumpPage(WidgetTester tester, int profileId) async {
  tester.view.physicalSize = const Size(1400, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: globalState.container,
      child: TestApp(
        locale: const Locale('en'),
        child: GeneralSettingsView(profileId: profileId),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders the general settings rows', (tester) async {
    final profile = Profile.normal(label: 'general');
    final setup = _RecordingSetupAction();
    _container(profile, setup);

    await _pumpPage(tester, profile.id);

    expect(find.text('General Settings'), findsOneWidget);
    expect(find.text('DNS Servers'), findsOneWidget);
    expect(find.text('Fallback DNS Servers'), findsOneWidget);
    expect(find.text('Direct DNS Servers'), findsOneWidget);
    expect(find.text('Skip Proxy'), findsOneWidget);
    expect(find.text('TUN Excluded Routes'), findsOneWidget);
    expect(find.text('TUN Included Routes'), findsOneWidget);
    expect(find.text('IPv6'), findsOneWidget);
    expect(find.text('Not supported by the core'), findsNWidgets(3));
  });

  testWidgets('shows the include URL when the profile has one', (tester) async {
    final profile = Profile.normal(label: 'general').copyWith(
      generalSettings: const GeneralSettings(
        include: 'https://example.com/remote.conf',
      ),
    );
    final setup = _RecordingSetupAction();
    _container(profile, setup);

    await _pumpPage(tester, profile.id);

    expect(find.text('Include URL'), findsOneWidget);
    expect(find.text('https://example.com/remote.conf'), findsOneWidget);
  });

  testWidgets('shows stored values on the unsupported core rows', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'general').copyWith(
      generalSettings: const GeneralSettings(
        preferIpv6: true,
        privateIpAnswer: false,
      ),
    );
    final setup = _RecordingSetupAction();
    _container(profile, setup);

    await _pumpPage(tester, profile.id);

    expect(find.text('On (Not supported by the core)'), findsOneWidget);
    expect(find.text('Off (Not supported by the core)'), findsOneWidget);
    expect(find.text('Not supported by the core'), findsOneWidget);
  });

  testWidgets('picking an IPv6 option saves it to the profile', (tester) async {
    final profile = Profile.normal(label: 'general');
    final setup = _RecordingSetupAction();
    final container = _container(profile, setup);

    await _pumpPage(tester, profile.id);

    await tester.tap(find.text('Follow global setting'));
    await tester.pump();
    await tester.tap(find.text('IPv6 on'));
    await tester.pump();
    await tester.tap(find.text('Submit'));
    await tester.pump();

    final saved = container
        .read(profilesProvider)
        .singleWhere((item) => item.id == profile.id);
    expect(saved.generalSettings.ipv6, isTrue);
    expect(find.text('IPv6 on'), findsWidgets);
  });

  testWidgets('unmounting the page applies the profile', (tester) async {
    final profile = Profile.normal(label: 'general');
    final setup = _RecordingSetupAction();
    _container(profile, setup);

    await _pumpPage(tester, profile.id);
    await tester.pumpWidget(const SizedBox.shrink());

    expect(setup.autoApplyCalls, 1);
  });
}
