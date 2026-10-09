import 'dart:io';
import 'dart:ui' as ui;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _FakeCoreController extends Mock implements CoreController {}

String? get _shotsDir {
  final dir = Platform.environment['ECLIPSE_SHOTS_DIR'];
  if (dir == null || dir.isEmpty) return null;
  return dir;
}

Future<ByteData> _loadFontFile(String path) async {
  final bytes = await File(path).readAsBytes();
  return ByteData.view(bytes.buffer);
}

Future<void> _loadFonts() async {
  const regularPath = '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc';
  const boldPath = '/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc';
  if (await File(regularPath).exists()) {
    final loader = FontLoader('NotoSansCJK')
      ..addFont(_loadFontFile(regularPath));
    await loader.load();
  }
  if (await File(boldPath).exists()) {
    final loader = FontLoader('NotoSansCJK')..addFont(_loadFontFile(boldPath));
    await loader.load();
  }
  const iconsPath =
      '/home/hatch/workspace/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf';
  if (await File(iconsPath).exists()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(_loadFontFile(iconsPath));
    await loader.load();
  }
}

ThemeData _desktopTheme(Brightness brightness) {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: brightness == Brightness.dark
        ? const ColorScheme.dark().eclipseDesktop
        : const ColorScheme.light().eclipseDesktop,
  ).withDesktopTheme(brightness);
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'NotoSansCJK'),
  );
}

List<Override> _overrides() {
  final proxies = List.generate(
    6,
    (i) => Proxy(name: 'Node ${i + 1}', type: i == 0 ? 'Direct' : 'VLESS'),
  );
  final group = Group(
    name: 'Proxy',
    type: GroupType.Selector,
    hidden: false,
    now: 'Node 2',
    all: proxies,
  );
  final profile = Profile.normal().copyWith(id: 1, label: 'My Config');
  final core = _FakeCoreController();
  when(() => core.getConnections()).thenAnswer((_) async => []);
  return [
    isStartProvider.overrideWithValue(true),
    currentGroupsStateProvider.overrideWithValue(GroupsState(value: [group])),
    groupsProvider.overrideWithValue([group]),
    profilesProvider.overrideWith(() => TestProfiles([profile])),
    currentProfileIdProvider.overrideWithBuild((_, _) => 1),
    coreHandlerProvider.overrideWithValue(core),
    viewSizeProvider.overrideWithBuild((_, _) => const Size(1280, 800)),
  ];
}

Future<void> _screenshot(
  WidgetTester tester,
  Widget page,
  String name,
  Brightness brightness,
) async {
  final dir = _shotsDir;
  if (dir == null) return;
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  final boundaryKey = GlobalKey();
  await tester.pumpWidget(
    TestApp(
      wrapInProviderScope: true,
      overrides: _overrides(),
      homeBuilder: (child) => Theme(
        data: _desktopTheme(brightness),
        child: Scaffold(
          body: RepaintBoundary(key: boundaryKey, child: child),
        ),
      ),
      child: page,
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  final boundary =
      boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$dir/$name.png');
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

void main() {
  final dir = _shotsDir;
  if (dir == null) {
    test('screenshots skipped (ECLIPSE_SHOTS_DIR not set)', () {});
    return;
  }

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
  });

  group('desktop screenshots', () {
    for (final brightness in Brightness.values) {
      final suffix = brightness == Brightness.dark ? 'dark' : 'light';
      testWidgets('home $suffix', (tester) async {
        await _screenshot(
          tester,
          const DesktopHomeView(),
          'b1-home-$suffix',
          brightness,
        );
      });
      testWidgets('config $suffix', (tester) async {
        await _screenshot(
          tester,
          const DesktopConfigView(),
          'b2-config-$suffix',
          brightness,
        );
      });
      testWidgets('modules $suffix', (tester) async {
        await _screenshot(
          tester,
          const DesktopModulesView(),
          'b3-modules-$suffix',
          brightness,
        );
      });
      testWidgets('data $suffix', (tester) async {
        await _screenshot(
          tester,
          const DesktopDataView(),
          'b4-data-$suffix',
          brightness,
        );
      });
      testWidgets('settings $suffix', (tester) async {
        await _screenshot(
          tester,
          const DesktopSettingsView(),
          'b5-settings-$suffix',
          brightness,
        );
      });
    }
  });
}
