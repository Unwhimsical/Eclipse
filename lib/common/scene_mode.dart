import 'package:collection/collection.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

const sceneModeDebounce = Duration(seconds: 4);

Scene? matchScene(
  List<Scene> scenes, {
  required bool isWifi,
  required String? ssid,
  required bool isCellular,
}) {
  if (isWifi && ssid != null && ssid.isNotEmpty) {
    final hit = scenes.firstWhereOrNull(
      (s) => s.triggerType == SceneTriggerType.ssid && s.ssid == ssid,
    );
    if (hit != null) return hit;
  }
  if (isCellular) {
    final hit = scenes.firstWhereOrNull(
      (s) => s.triggerType == SceneTriggerType.cellular,
    );
    if (hit != null) return hit;
  }
  return scenes.firstWhereOrNull(
    (s) => s.triggerType == SceneTriggerType.fallback,
  );
}

String sceneApplyKey(Scene scene, bool isWifi, String? ssid, bool isCellular) {
  final trigger = isWifi
      ? 'wifi:${ssid ?? ''}'
      : (isCellular ? 'cellular' : 'none');
  return '${scene.id}@$trigger';
}

/// Subtitle for the scene mode settings entry. iOS only reveals the SSID
/// while the app is in the foreground, so the caveat is stated up front.
String sceneModeEntrySubtitle({required bool isIOS, required String base}) {
  return isIOS ? '$base（iOS 仅在 App 处于前台时生效）' : base;
}
