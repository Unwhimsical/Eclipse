import 'package:fl_clash/common/tray.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:riverpod/riverpod.dart';
import 'package:tray/tray.dart';
import 'dart:io';

const _channel = MethodChannel('tray');

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

TrayState _trayState({bool isStart = false}) {
  return TrayState(
    mode: Mode.rule,
    port: 7890,
    autoLaunch: false,
    systemProxy: false,
    tunEnable: false,
    isStart: isStart,
    groups: const [],
    selectedMap: const {},
    showTrayTitle: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> calls;
  late ProviderContainer container;

  setUpAll(() async {
    final root = await Directory.systemTemp.createTemp('tray_lifecycle_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    await AppLocalizations.load(const Locale('en'));
  });

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    calls = [];
    container = ProviderContainer();
    Tray.instance.resetForTesting();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return true;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    container.dispose();
    debugDefaultTargetPlatformOverride = null;
  });

  test('shutdown stops any later update from resurrecting the tray', () async {
    await AppTray().update(
      trayState: _trayState(),
      traffic: const Traffic(),
      read: container.read,
    );
    expect(calls.where((call) => call.method == 'show'), hasLength(1));

    await AppTray().shutdown();
    expect(calls.where((call) => call.method == 'hide'), hasLength(1));

    calls.clear();
    await AppTray().update(
      trayState: _trayState(isStart: true),
      traffic: const Traffic(),
      read: container.read,
    );
    await AppTray().updateTitle(showTrayTitle: true, traffic: const Traffic());

    expect(calls, isEmpty);
  });
}
