import 'package:fl_clash/views/desktop/desktop.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData _desktopTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark().eclipseDesktop,
  ).withDesktopTheme(Brightness.dark);
}

Future<void> _pumpHeader(
  WidgetTester tester, {
  ThemeData? theme,
  List<Widget> actions = const [],
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: theme ?? _desktopTheme(),
      home: Scaffold(
        body: DesktopPageHeader(title: 'Dashboard', actions: actions),
      ),
    ),
  );
}

void main() {
  group('DesktopPageHeader', () {
    testWidgets('renders the title with the page title token', (tester) async {
      await _pumpHeader(tester);
      await tester.pump();

      final title = tester.widget<Text>(find.text('Dashboard'));
      expect(title.style?.fontSize, 22);
      expect(title.style?.fontWeight, FontWeight.w700);
      expect(title.style?.color, const Color(0xFFF1F1F8));
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays actions out to the right of the title', (tester) async {
      await _pumpHeader(
        tester,
        actions: [TextButton(onPressed: () {}, child: const Text('Run'))],
      );
      await tester.pump();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Run'), findsOneWidget);
      final titleX = tester.getCenter(find.text('Dashboard')).dx;
      final actionX = tester.getCenter(find.text('Run')).dx;
      expect(actionX, greaterThan(titleX));
      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back to headlineSmall without the desktop theme', (
      tester,
    ) async {
      await _pumpHeader(tester, theme: ThemeData(useMaterial3: true));
      await tester.pump();

      final theme = Theme.of(tester.element(find.text('Dashboard')));
      expect(theme.extension<DesktopThemeTokens>(), isNull);
      final title = tester.widget<Text>(find.text('Dashboard'));
      expect(title.style, theme.textTheme.headlineSmall);
      expect(tester.takeException(), isNull);
    });
  });
}
