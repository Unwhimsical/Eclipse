import 'dart:async';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/scene_mode.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wifi_ssid/wifi_ssid.dart';

import 'providers.dart';

part 'generated/scene.g.dart';

@Riverpod(keepAlive: true)
class SceneMode extends _$SceneMode {
  Timer? _debounceTimer;
  List<ConnectivityResult> _latestResults = const [];
  String? _lastAppliedKey;
  Future<String?> Function() _readSsid = WifiSsidManager.instance.getSsid;

  @override
  void build() {
    ref.onDispose(() => _debounceTimer?.cancel());
  }

  @visibleForTesting
  set readSsid(Future<String?> Function() reader) => _readSsid = reader;

  void onConnectivityChanged(List<ConnectivityResult> results) {
    _latestResults = results;
    _debounceTimer?.cancel();
    if (!ref.read(sceneModeEnabledProvider)) return;
    _debounceTimer = Timer(sceneModeDebounce, _evaluate);
  }

  Future<void> _evaluate() async {
    if (!ref.read(sceneModeEnabledProvider)) return;
    final results = _latestResults;
    final isWifi = results.contains(ConnectivityResult.wifi);
    final isCellular = results.contains(ConnectivityResult.mobile);
    final scenes = ref.read(sceneListProvider).value ?? const <Scene>[];
    String? ssid;
    if (isWifi &&
        scenes.any((scene) => scene.triggerType == SceneTriggerType.ssid)) {
      try {
        ssid = await _readSsid();
      } catch (_) {
        ssid = null;
      }
    }
    final scene = matchScene(
      scenes,
      isWifi: isWifi,
      ssid: ssid,
      isCellular: isCellular,
    );
    if (scene == null) return;
    final key = sceneApplyKey(scene, isWifi, ssid, isCellular);
    if (key == _lastAppliedKey) return;
    _lastAppliedKey = key;
    await _applyScene(scene);
  }

  Future<void> _applyScene(Scene scene) async {
    try {
      final targetProfileId = scene.targetProfileId;
      if (targetProfileId != null) {
        final target = ref
            .read(profilesProvider)
            .firstWhereOrNull((profile) => profile.id == targetProfileId);
        if (target == null) {
          dialogs.showNotifier(
            '场景目标配置不存在，已保持当前配置',
            level: MessageLevel.warning,
          );
          return;
        }
        final targetProxy = scene.targetProxy;
        final groupName = target.currentGroupName;
        if (targetProxy != null &&
            targetProxy.isNotEmpty &&
            groupName != null &&
            target.selectedMap[groupName] != targetProxy) {
          final selectedMap = Map<String, String>.from(target.selectedMap)
            ..[groupName] = targetProxy;
          ref
              .read(profilesProvider.notifier)
              .put(target.copyWith(selectedMap: selectedMap));
        }
        ref.read(currentProfileIdProvider.notifier).value = targetProfileId;
      }
      final mode = scene.mode;
      if (mode != null) {
        ref
            .read(patchClashConfigProvider.notifier)
            .update((state) => state.copyWith(mode: mode));
      }
      if (targetProfileId == null) {
        ref
            .read(setupActionProvider.notifier)
            .applyProfileDebounce(silence: true);
      }
    } catch (e) {
      dialogs.showNotifier('场景切换失败：$e', level: MessageLevel.error);
    }
  }
}
