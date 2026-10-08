import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

List<NavigationItem> _items() => [
  NavigationItem(
    icon: const Icon(Icons.dashboard_outlined),
    label: PageLabel.dashboard,
    builder: (_) => const SizedBox(),
  ),
  NavigationItem(
    icon: const Icon(Icons.description_outlined),
    label: PageLabel.config,
    builder: (_) => const SizedBox(),
  ),
  NavigationItem(
    icon: const Icon(Icons.extension_outlined),
    label: PageLabel.modules,
    builder: (_) => const SizedBox(),
  ),
  NavigationItem(
    icon: const Icon(Icons.analytics_outlined),
    label: PageLabel.data,
    builder: (_) => const SizedBox(),
  ),
  NavigationItem(
    icon: const Icon(Icons.settings_outlined),
    label: PageLabel.settings,
    builder: (_) => const SizedBox(),
  ),
];

ThemeData _desktopTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark().eclipseDesktop.eclipseDesktopPrimary,
  ).withDesktopTheme(Brightness.dark);
}

Future<void> _pumpNav(
  WidgetTester tester, {
  int currentIndex = 0,
  ValueChanged<int>? onSelected,
  String version = '1.2.3',
  bool isRunning = false,
  bool isMacOS = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      theme: _desktopTheme(),
      home: Scaffold(
        body: DesktopSideNav(
          items: _items(),
          currentIndex: currentIndex,
          onSelected: onSelected ?? (_) {},
          version: version,
          isRunning: isRunning,
          isMacOS: isMacOS,
        ),
      ),
    ),
  );
}

Finder get _handle => find.byWidgetPredicate(
  (widget) =>
      widget is MouseRegion && widget.cursor == SystemMouseCursors.resizeColumn,
);

Finder _sideBarPane() => find.byKey(const ValueKey('desktopSideNavPane'));

double _paneWidth(WidgetTester tester) => tester.getSize(_sideBarPane()).width;

void main() {
  group('DesktopSideNav', () {
    testWidgets('renders five items expanded with labels', (tester) async {
      await _pumpNav(tester);
      await tester.pump();

      for (final label in ['Home', 'Config', 'Modules', 'Data', 'Settings']) {
        expect(find.text(label), findsOneWidget);
      }
      expect(_paneWidth(tester), DesktopSideNav.expandedWidth);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tap selects the page', (tester) async {
      var selected = -1;
      await _pumpNav(tester, onSelected: (index) => selected = index);
      await tester.pump();

      await tester.tap(find.text('Data'));
      expect(selected, 3);
      expect(tester.takeException(), isNull);
    });

    testWidgets('selected item uses the accent capsule', (tester) async {
      await _pumpNav(tester, currentIndex: 2);
      await tester.pump();

      final capsule = find
          .ancestor(
            of: find.text('Modules'),
            matching: find.byType(AnimatedContainer),
          )
          .first;
      final decoration =
          tester.widget<AnimatedContainer>(capsule).decoration
              as ShapeDecoration;
      expect(decoration.color, const Color(0x249F51E3));
      expect(tester.takeException(), isNull);
    });

    testWidgets('drag collapses to 68 and hides labels', (tester) async {
      await _pumpNav(tester);
      await tester.pump();

      await tester.drag(_handle, const Offset(-140, 0));
      await tester.pump();

      expect(_paneWidth(tester), DesktopSideNav.collapsedWidth);
      expect(find.text('Home'), findsNothing);
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Tooltip && widget.message == 'Home',
        ),
        findsOneWidget,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('double-tap toggles between 68 and 208', (tester) async {
      await _pumpNav(tester);
      await tester.pump();

      final center = tester.getCenter(_handle);
      final gesture = await tester.startGesture(center);
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.down(center);
      await gesture.up();
      await tester.pump();

      expect(_paneWidth(tester), DesktopSideNav.collapsedWidth);

      final gesture2 = await tester.startGesture(tester.getCenter(_handle));
      await gesture2.up();
      await tester.pump(const Duration(milliseconds: 100));
      await gesture2.down(tester.getCenter(_handle));
      await gesture2.up();
      await tester.pump();

      expect(_paneWidth(tester), DesktopSideNav.expandedWidth);
      expect(find.text('Home'), findsOneWidget);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('arrow keys move focus and enter activates', (tester) async {
      var selected = -1;
      await _pumpNav(tester, onSelected: (index) => selected = index);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();

      expect(selected, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keyboard focus shows the accent ring', (tester) async {
      await _pumpNav(tester);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.decoration is ShapeDecoration &&
              (widget.decoration as ShapeDecoration).shape
                  is RoundedSuperellipseBorder &&
              ((widget.decoration as ShapeDecoration).shape
                          as RoundedSuperellipseBorder)
                      .side
                      .color ==
                  const Color(0xFF9F51E3).withValues(alpha: 0.6),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('footer gear jumps to settings and shows the version', (
      tester,
    ) async {
      var selected = -1;
      await _pumpNav(tester, onSelected: (index) => selected = index);
      await tester.pump();

      expect(find.text('1.2.3'), findsOneWidget);
      await tester.tap(find.byTooltip('Settings'));
      expect(selected, 4);
      expect(tester.takeException(), isNull);
    });

    testWidgets('macOS build reserves traffic-light space', (tester) async {
      await _pumpNav(tester, isMacOS: true);
      await tester.pump();

      expect(find.byType(DesktopSideNav), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
