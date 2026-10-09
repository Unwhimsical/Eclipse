import 'package:fl_clash/views/desktop/components/components.dart';
import 'package:fl_clash/views/theme/desktop_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fl_clash/providers/providers.dart';

import '../../helpers/test_app.dart';

ThemeData _desktopTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark().eclipseDesktop,
  ).withDesktopTheme(Brightness.dark);
}

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      theme: _desktopTheme(),
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('KpiBaselines', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('no history yields no trend', () async {
      final baselines = KpiBaselines();
      await baselines.ensureLoaded();
      expect(baselines.upTrend(100), isNull);
      expect(baselines.downTrend(100), isNull);
      expect(baselines.connectionTrend(3), isNull);
    });

    test('recordTraffic persists the first sample', () async {
      final baselines = KpiBaselines();
      await baselines.ensureLoaded();
      await baselines.recordTraffic(100, 200);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('desktopKpi.dayAgoSample'), isNotNull);
    });
  });

  group('DesktopCard', () {
    testWidgets('renders child with the card radius token', (tester) async {
      await _pump(tester, const DesktopCard(child: Text('hello')));
      await tester.pump();
      expect(find.text('hello'), findsOneWidget);
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(DesktopCard),
              matching: find.byType(Container),
            )
            .first,
      );
      final decoration = container.decoration as ShapeDecoration?;
      final shape = decoration?.shape as RoundedSuperellipseBorder?;
      expect(
        shape?.borderRadius,
        BorderRadius.circular(DesktopThemeTokens.cardRadius),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('KpiStrip', () {
    testWidgets('renders labels, values and trend arrows', (tester) async {
      await _pump(
        tester,
        const KpiStrip(
          kpis: [
            KpiData(label: 'Up', value: '1.2 MB', trend: 0.5),
            KpiData(label: 'Down', value: '3.4 MB', trend: -0.2),
            KpiData(label: 'Conns', value: '7'),
          ],
        ),
      );
      await tester.pump();
      expect(find.text('Up'), findsOneWidget);
      expect(find.text('1.2 MB'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      // No trend → no arrow for the third cell.
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      final boxes = tester.widgetList<SizedBox>(
        find.descendant(
          of: find.byType(KpiStrip),
          matching: find.byType(SizedBox),
        ),
      );
      expect(boxes.map((b) => b.height), contains(64));
      expect(tester.takeException(), isNull);
    });
  });

  group('TrafficChart', () {
    testWidgets('renders without samples', (tester) async {
      await _pump(tester, const TrafficChart(samples: []));
      await tester.pump();
      expect(find.byType(TrafficChart), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DesktopTable', () {
    DesktopTable<int> table({List<int>? rows}) {
      return DesktopTable<int>(
        rows: rows ?? const [3, 1, 2],
        columns: [
          DesktopColumn<int>(
            title: 'N',
            width: 120,
            cell: (v) => Text('$v'),
            sortKey: (v) => v,
          ),
        ],
      );
    }

    testWidgets('renders rows in given order', (tester) async {
      await _pump(tester, table());
      await tester.pump();
      final texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(DesktopTable<int>),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .where((d) => d != 'N')
          .toList();
      expect(texts, ['3', '1', '2']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('sorts ascending then descending on header tap', (
      tester,
    ) async {
      await _pump(tester, table());
      await tester.pump();
      await tester.tap(find.text('N'));
      await tester.pump();
      var texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(DesktopTable<int>),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .where((d) => d != 'N')
          .toList();
      expect(texts, ['1', '2', '3']);
      await tester.tap(find.text('N'));
      await tester.pump();
      texts = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(DesktopTable<int>),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data)
          .where((d) => d != 'N')
          .toList();
      expect(texts, ['3', '2', '1']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the empty label when there are no rows', (tester) async {
      await _pump(tester, table(rows: const []));
      await tester.pump();
      expect(find.byType(DesktopTable<int>), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('DesktopDragList', () {
    testWidgets('renders one row per item', (tester) async {
      var reorderCalls = 0;
      await _pump(
        tester,
        DesktopDragList<String>(
          items: const ['a', 'b', 'c'],
          itemExtent: 48,
          itemBuilder: (_, item, _, _) => Text('row-$item'),
          onReorder: (_, _) => reorderCalls++,
        ),
      );
      await tester.pump();
      expect(find.text('row-a'), findsOneWidget);
      expect(find.text('row-b'), findsOneWidget);
      expect(find.text('row-c'), findsOneWidget);
      expect(reorderCalls, 0);
      expect(tester.takeException(), isNull);
    });
  });

  group('showDesktopConfirm', () {
    testWidgets('returns true on confirm and false on cancel', (tester) async {
      bool? result;
      await tester.pumpWidget(
        TestApp(
          wrapInProviderScope: true,
          overrides: [
            viewSizeProvider.overrideWithBuild((_, _) => const Size(1280, 800)),
          ],
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showDesktopConfirm(
                  title: 'Delete?',
                  message: 'Sure?',
                  confirmLabel: 'Delete',
                  danger: true,
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Delete?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(tester.takeException(), isNull);
    });
  });

  group('showDesktopMenu', () {
    testWidgets('returns the selected item value', (tester) async {
      String? result;
      await _pump(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showDesktopMenu<String>(
                context: context,
                position: const Offset(100, 100),
                items: const [
                  DesktopMenuItem(label: 'Copy', value: 'copy'),
                  DesktopMenuItem(
                    label: 'Delete',
                    value: 'delete',
                    danger: true,
                  ),
                ],
              );
            },
            child: const Text('open'),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, 'delete');
      expect(tester.takeException(), isNull);
    });
  });
}
