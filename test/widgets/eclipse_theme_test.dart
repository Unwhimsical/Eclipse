import 'package:fl_clash/views/theme/components.dart';
import 'package:fl_clash/views/theme/eclipse_theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  group('EclipsePalette', () {
    test('defines the violet primary pair', () {
      expect(EclipsePalette.primary, const Color(0xFF8B7CF6));
      expect(EclipsePalette.lightPrimary, const Color(0xFF7C6CF0));
    });

    test('eclipse scheme keeps surfaces on the eclipse ramp', () {
      final dark = const ColorScheme.dark().eclipse;
      expect(dark.surface, EclipsePalette.darkBackground);
      expect(dark.surfaceContainerLowest, EclipsePalette.darkLowest);
      final light = const ColorScheme.light().eclipse;
      expect(light.surface, EclipsePalette.lightBackground);
    });

    test('eclipsePrimary forces the violet primary', () {
      final dark = const ColorScheme.dark().eclipsePrimary;
      expect(dark.primary, EclipsePalette.primary);
      final light = const ColorScheme.light().eclipsePrimary;
      expect(light.primary, EclipsePalette.lightPrimary);
    });
  });

  group('Eclipse components', () {
    testWidgets('section renders title and children', (tester) async {
      await tester.pumpWidget(
        const TestApp(
          wrapInProviderScope: true,
          child: Scaffold(
            body: EclipseSection(
              title: 'Section',
              children: [EclipseTile(title: 'Row')],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Section'), findsOneWidget);
      expect(find.text('Row'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tile tap fires', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          child: Scaffold(
            body: EclipseSection(
              children: [EclipseTile(title: 'Row', onTap: () => tapped = true)],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Row'));
      expect(tapped, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('open tile navigates to the page', (tester) async {
      await tester.pumpWidget(
        const TestApp(
          wrapInProviderScope: true,
          child: Scaffold(
            body: EclipseSection(
              children: [
                EclipseOpenTile(title: 'Open me', page: Text('Target page')),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Open me'));
      await tester.pumpAndSettle();
      expect(find.text('Target page'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('coming soon view shows its title', (tester) async {
      await tester.pumpWidget(
        const TestApp(
          wrapInProviderScope: true,
          child: ComingSoonView(title: 'Soon'),
        ),
      );
      await tester.pump();
      expect(find.text('Soon'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });
}
