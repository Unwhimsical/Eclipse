import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fake_async/fake_async.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_profiles.dart';

class _TestScenes extends SceneList {
  final List<Scene> initial;

  _TestScenes(this.initial);

  @override
  Stream<List<Scene>> build() => Stream.value(initial);
}

Scene _scene({
  int id = 1,
  SceneTriggerType triggerType = SceneTriggerType.ssid,
  String? ssid,
  int? targetProfileId = 2,
  Mode? mode,
  String? targetProxy,
  int order = 0,
}) {
  return Scene(
    id: id,
    name: 'scene $id',
    triggerType: triggerType,
    ssid: ssid,
    targetProfileId: targetProfileId,
    mode: mode,
    targetProxy: targetProxy,
    order: order,
  );
}

Profile _profile(int id) => Profile.normal(label: 'p$id').copyWith(
  id: id,
  currentGroupName: 'PROXY',
  selectedMap: const {'PROXY': 'A'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const wifiHome = [ConnectivityResult.wifi];
  const cellular = [ConnectivityResult.mobile];

  late ProviderContainer container;
  late String? fakeSsid;
  late List<Scene> scenes;

  ProviderContainer makeContainer({bool enabled = true}) {
    final c = ProviderContainer(
      overrides: [
        sceneModeEnabledProvider.overrideWithBuild((_, _) => enabled),
        profilesProvider.overrideWith(
          () => TestProfiles([_profile(1), _profile(2)]),
        ),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        sceneListProvider.overrideWith(() => _TestScenes(scenes)),
      ],
    );
    addTearDown(c.dispose);
    c.listen(currentProfileIdProvider, (_, _) {});
    c.listen(patchClashConfigProvider, (_, _) {});
    c.read(sceneModeProvider.notifier).readSsid = () async => fakeSsid;
    return c;
  }

  void settle(FakeAsync async) {
    async.elapse(const Duration(seconds: 5));
    async.flushMicrotasks();
  }

  setUp(() {
    fakeSsid = 'home';
    scenes = const [];
  });

  group('scene switching', () {
    test('wifi with a matching ssid switches profile, mode and proxy', () {
      scenes = [
        _scene(
          ssid: 'home',
          targetProfileId: 2,
          mode: Mode.global,
          targetProxy: 'B',
        ),
      ];
      fakeAsync((async) {
        container = makeContainer();
        container.listen(sceneListProvider, (_, _) {});
        async.flushMicrotasks();
        container
            .read(sceneModeProvider.notifier)
            .onConnectivityChanged(wifiHome);
        settle(async);

        expect(container.read(currentProfileIdProvider), 2);
        expect(container.read(patchClashConfigProvider).mode, Mode.global);
        expect(
          container
              .read(profilesProvider)
              .firstWhere((p) => p.id == 2)
              .selectedMap['PROXY'],
          'B',
        );
      });
    });

    test('rapid flaps only apply the last stable network', () {
      scenes = [
        _scene(id: 1, ssid: 'home', targetProfileId: 2),
        _scene(
          id: 2,
          triggerType: SceneTriggerType.cellular,
          targetProfileId: 2,
        ),
      ];
      fakeAsync((async) {
        container = makeContainer();
        container.listen(sceneListProvider, (_, _) {});
        async.flushMicrotasks();
        final notifier = container.read(sceneModeProvider.notifier);
        fakeSsid = 'home';
        notifier.onConnectivityChanged(wifiHome);
        async.elapse(const Duration(seconds: 1));
        fakeSsid = null;
        notifier.onConnectivityChanged(cellular);
        settle(async);

        expect(container.read(currentProfileIdProvider), 2);
      });
    });

    test('the same trigger does not re-apply the scene', () {
      scenes = [_scene(ssid: 'home', targetProfileId: 2)];
      fakeAsync((async) {
        container = makeContainer();
        container.listen(sceneListProvider, (_, _) {});
        async.flushMicrotasks();
        final notifier = container.read(sceneModeProvider.notifier);
        notifier.onConnectivityChanged(wifiHome);
        settle(async);
        expect(container.read(currentProfileIdProvider), 2);

        container.read(currentProfileIdProvider.notifier).value = 1;
        notifier.onConnectivityChanged(wifiHome);
        settle(async);

        expect(
          container.read(currentProfileIdProvider),
          1,
          reason: 'the manual switch must not be yanked back by a re-flap',
        );
      });
    });

    test('cellular trigger switches when wifi does not match', () {
      scenes = [
        _scene(
          id: 2,
          triggerType: SceneTriggerType.cellular,
          targetProfileId: 2,
          mode: Mode.direct,
        ),
      ];
      fakeAsync((async) {
        container = makeContainer();
        container.listen(sceneListProvider, (_, _) {});
        async.flushMicrotasks();
        container
            .read(sceneModeProvider.notifier)
            .onConnectivityChanged(cellular);
        settle(async);

        expect(container.read(currentProfileIdProvider), 2);
        expect(container.read(patchClashConfigProvider).mode, Mode.direct);
      });
    });

    test('a scene without target profile only applies mode', () {
      scenes = [_scene(ssid: 'home', targetProfileId: null, mode: Mode.global)];
      fakeAsync((async) {
        container = makeContainer();
        container.listen(sceneListProvider, (_, _) {});
        async.flushMicrotasks();
        container
            .read(sceneModeProvider.notifier)
            .onConnectivityChanged(wifiHome);
        settle(async);

        expect(container.read(currentProfileIdProvider), 1);
        expect(container.read(patchClashConfigProvider).mode, Mode.global);
      });
    });

    test('a missing target profile keeps the current configuration', () {
      scenes = [_scene(ssid: 'home', targetProfileId: 99, mode: Mode.global)];
      fakeAsync((async) {
        container = makeContainer();
        container.listen(sceneListProvider, (_, _) {});
        async.flushMicrotasks();
        container
            .read(sceneModeProvider.notifier)
            .onConnectivityChanged(wifiHome);
        settle(async);

        expect(container.read(currentProfileIdProvider), 1);
        expect(
          container.read(patchClashConfigProvider).mode,
          isNot(Mode.global),
        );
      });
    });

    test('nothing happens while scene mode is disabled', () {
      scenes = [_scene(ssid: 'home', targetProfileId: 2)];
      fakeAsync((async) {
        container = makeContainer(enabled: false);
        container
            .read(sceneModeProvider.notifier)
            .onConnectivityChanged(wifiHome);
        settle(async);

        expect(container.read(currentProfileIdProvider), 1);
      });
    });

    test('unreadable ssid falls through to lower priority scenes', () {
      scenes = [
        _scene(id: 1, ssid: 'home', targetProfileId: 2),
        _scene(
          id: 2,
          triggerType: SceneTriggerType.fallback,
          targetProfileId: 2,
        ),
      ];
      fakeAsync((async) {
        container = makeContainer();
        container.listen(sceneListProvider, (_, _) {});
        async.flushMicrotasks();
        fakeSsid = null;
        container
            .read(sceneModeProvider.notifier)
            .onConnectivityChanged(wifiHome);
        settle(async);

        expect(container.read(currentProfileIdProvider), 2);
      });
    });
  });
}
