import 'dart:io';
import 'dart:ui' as ui;

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData _desktopTheme(Brightness brightness) {
  final scheme =
      (brightness == Brightness.dark
              ? const ColorScheme.dark()
              : const ColorScheme.light())
          .eclipseDesktop
          .eclipseDesktopPrimary;
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'NotoSansCJK',
  ).withDesktopTheme(brightness);
}

Future<void> _loadFonts() async {
  Future<void> load(String family, String path) async {
    final bytes = await File(path).readAsBytes();
    final loader = FontLoader(family)
      ..addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  await load(
    'NotoSansCJK',
    '/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc',
  );
  await load(
    'MaterialIcons',
    '/home/hatch/workspace/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
}

List<NavigationItem> _navItems() => [
  NavigationItem(
    icon: const Icon(Icons.home_rounded),
    label: PageLabel.dashboard,
    builder: (_) => const SizedBox.shrink(),
  ),
  NavigationItem(
    icon: const Icon(Icons.description_outlined),
    label: PageLabel.config,
    builder: (_) => const SizedBox.shrink(),
  ),
  NavigationItem(
    icon: const Icon(Icons.extension_outlined),
    label: PageLabel.modules,
    builder: (_) => const SizedBox.shrink(),
  ),
  NavigationItem(
    icon: const Icon(Icons.analytics_outlined),
    label: PageLabel.data,
    builder: (_) => const SizedBox.shrink(),
  ),
  NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    label: PageLabel.settings,
    builder: (_) => const SizedBox.shrink(),
  ),
];

Widget _statCard(String label, String value, Color color) {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      return Expanded(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _homeBody() {
  return Builder(
    builder: (context) {
      final tokens = Theme.of(context).extension<DesktopThemeTokens>()!;
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              _statCard('延迟', '86 ms', tokens.success),
              const SizedBox(width: 16),
              _statCard('上传', '12.4 MB/s', tokens.accent),
              const SizedBox(width: 16),
              _statCard('下载', '48.1 MB/s', tokens.accent),
            ],
          ),
          const SizedBox(height: 8),
          EclipseSection(
            title: '运行状态',
            children: [
              Builder(
                builder: (context) {
                  final theme = Theme.of(context);
                  return Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: tokens.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('核心运行中', style: theme.textTheme.bodyLarge),
                      const Spacer(),
                      Switch(value: true, onChanged: (_) {}),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

Widget _configBody() {
  return Builder(
    builder: (context) {
      final theme = Theme.of(context);
      final tokens = theme.extension<DesktopThemeTokens>()!;
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          EclipseSection(
            title: '配置文件',
            trailing: TextButton(onPressed: () {}, child: const Text('导入')),
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: i == 0 ? tokens.accent : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '配置 ${i + 1}',
                              style: theme.textTheme.bodyLarge,
                            ),
                            Text(
                              'updated 2h ago',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      if (i == 0)
                        Icon(Icons.check_circle, color: tokens.success),
                    ],
                  ),
                ),
            ],
          ),
        ],
      );
    },
  );
}

Widget _homeActions() {
  return Builder(
    builder: (context) {
      final tokens = Theme.of(context).extension<DesktopThemeTokens>()!;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: tokens.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text('运行中'),
        ],
      );
    },
  );
}

Future<void> _capture(
  WidgetTester tester,
  String fileName, {
  required int currentIndex,
  required String title,
  required List<Widget> actions,
  required Widget body,
  required Brightness brightness,
}) async {
  final outDir = Platform.environment['ECLIPSE_SHOTS_DIR'];
  if (outDir == null || outDir.isEmpty) return;
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _desktopTheme(brightness),
      locale: const Locale('zh', 'CN'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      home: Scaffold(
        body: RepaintBoundary(
          key: const ValueKey('shot-boundary'),
          child: SizedBox(
            width: 1280,
            height: 800,
            child: Row(
              children: [
                DesktopSideNav(
                  items: _navItems(),
                  currentIndex: currentIndex,
                  onSelected: (_) {},
                  version: '0.8.98',
                  isRunning: true,
                  isMacOS: false,
                ),
                Expanded(
                  child: Column(
                    children: [
                      DesktopPageHeader(title: title, actions: actions),
                      Expanded(child: body),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 500));

  final boundary =
      tester.element(find.byKey(const ValueKey('shot-boundary'))).renderObject
          as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  // Real dart:io hangs inside the fake-async test zone; run it for real.
  await tester.runAsync(
    () =>
        File('$outDir/$fileName').writeAsBytes(byteData!.buffer.asUint8List()),
  );
  expect(tester.takeException(), isNull);
}

void main() {
  setUpAll(_loadFonts);

  group('desktop shell screenshots', () {
    for (final brightness in [Brightness.dark, Brightness.light]) {
      final mode = brightness == Brightness.dark ? 'dark' : 'light';
      testWidgets('home shell $mode', (tester) async {
        await _capture(
          tester,
          'a1-shell-home-$mode.png',
          currentIndex: 0,
          title: '主页',
          actions: [_homeActions()],
          body: _homeBody(),
          brightness: brightness,
        );
      });
      testWidgets('config shell $mode', (tester) async {
        await _capture(
          tester,
          'a2-shell-config-$mode.png',
          currentIndex: 1,
          title: '配置',
          actions: [FilledButton(onPressed: () {}, child: const Text('新建配置'))],
          body: _configBody(),
          brightness: brightness,
        );
      });
    }
  });
}
