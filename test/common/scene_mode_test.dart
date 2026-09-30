import 'package:fl_clash/common/scene_mode.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';

Scene _scene({
  int id = 1,
  SceneTriggerType triggerType = SceneTriggerType.ssid,
  String? ssid,
  int order = 0,
}) {
  return Scene(
    id: id,
    name: 'scene $id',
    triggerType: triggerType,
    ssid: ssid,
    order: order,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('matchScene', () {
    test('matches the scene whose ssid equals the current one', () {
      final scenes = [
        _scene(id: 1, ssid: 'office'),
        _scene(id: 2, ssid: 'home'),
      ];

      final hit = matchScene(
        scenes,
        isWifi: true,
        ssid: 'home',
        isCellular: false,
      );

      expect(hit?.id, 2);
    });

    test('ssid match wins over cellular and fallback scenes', () {
      final scenes = [
        _scene(id: 1, triggerType: SceneTriggerType.fallback),
        _scene(id: 2, triggerType: SceneTriggerType.cellular),
        _scene(id: 3, ssid: 'home'),
      ];

      final hit = matchScene(
        scenes,
        isWifi: true,
        ssid: 'home',
        isCellular: true,
      );

      expect(hit?.id, 3);
    });

    test('falls back to the cellular scene when no ssid matches', () {
      final scenes = [
        _scene(id: 1, ssid: 'home'),
        _scene(id: 2, triggerType: SceneTriggerType.cellular),
        _scene(id: 3, triggerType: SceneTriggerType.fallback),
      ];

      final hit = matchScene(
        scenes,
        isWifi: true,
        ssid: 'unknown',
        isCellular: true,
      );

      expect(hit?.id, 2);
    });

    test('falls back to the fallback scene without wifi or cellular', () {
      final scenes = [
        _scene(id: 1, ssid: 'home'),
        _scene(id: 2, triggerType: SceneTriggerType.fallback),
      ];

      final hit = matchScene(
        scenes,
        isWifi: false,
        ssid: null,
        isCellular: false,
      );

      expect(hit?.id, 2);
    });

    test('returns null when nothing matches', () {
      final scenes = [_scene(id: 1, ssid: 'home')];

      expect(
        matchScene(scenes, isWifi: true, ssid: 'office', isCellular: false),
        isNull,
      );
      expect(
        matchScene(const [], isWifi: false, ssid: null, isCellular: false),
        isNull,
      );
    });

    test('an unreadable ssid behaves like no ssid match', () {
      final scenes = [
        _scene(id: 1, ssid: 'home'),
        _scene(id: 2, triggerType: SceneTriggerType.fallback),
      ];

      final hit = matchScene(
        scenes,
        isWifi: true,
        ssid: null,
        isCellular: false,
      );

      expect(hit?.id, 2);
    });
  });

  group('sceneApplyKey', () {
    test('same scene on the same trigger produces the same key', () {
      final scene = _scene(id: 1, ssid: 'home');

      expect(
        sceneApplyKey(scene, true, 'home', false),
        sceneApplyKey(scene, true, 'home', false),
      );
    });

    test('different triggers produce different keys', () {
      final scene = _scene(id: 1, ssid: 'home');

      expect(
        sceneApplyKey(scene, true, 'home', false),
        isNot(sceneApplyKey(scene, true, 'office', false)),
      );
      expect(
        sceneApplyKey(scene, true, 'home', false),
        isNot(sceneApplyKey(scene, false, null, true)),
      );
    });
  });

  group('sceneModeEntrySubtitle', () {
    test('returns the base text unchanged on non-iOS', () {
      expect(sceneModeEntrySubtitle(isIOS: false, base: 'desc'), 'desc');
    });

    test('appends the foreground-only caveat on iOS', () {
      expect(
        sceneModeEntrySubtitle(isIOS: true, base: 'desc'),
        'desc（iOS 仅在 App 处于前台时生效）',
      );
    });
  });
}
