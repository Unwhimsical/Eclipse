import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/module.dart';
import 'package:fl_clash/views/modules/modules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

ModuleInfo _info({bool enabled = true}) => ModuleInfo(
  id: 'mod-1',
  name: 'AdBlock',
  desc: 'blocks ads',
  author: 'tester',
  enabled: enabled,
  ruleCount: 10,
  hostCount: 2,
  rewriteCount: 1,
  scriptCount: 0,
  needsMitm: false,
  importDate: DateTime(2026, 1, 1),
  ruleSetRules: const [],
  rulesAppend: false,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ModulesView renders empty state when no modules imported', (
    tester,
  ) async {
    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: ModulesView()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ModulesView), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('ModulesView lists imported modules with toggle state', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await moduleStore.saveOrder([_info()]);
    });
    addTearDown(() async {
      await tester.runAsync(() async {
        await moduleStore.saveOrder([]);
      });
    });

    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: ModulesView()),
    );
    await tester.pumpAndSettle();

    expect(find.text('AdBlock'), findsOneWidget);
    final toggle = tester.widget<Switch>(find.byType(Switch).first);
    expect(toggle.value, isTrue);
  });
}
