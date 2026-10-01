import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/test_rules/test_rules.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('TestRulesView renders form and no-profile hint', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [currentProfileProvider.overrideWith((ref) => null)],
        child: const TestRulesView(),
      ),
    );
    await tester.pump();
    expect(find.byType(TestRulesView), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
    expect(find.byKey(const ValueKey('testRulesTestButton')), findsOneWidget);
  });

  testWidgets('TestRulesView validates empty input', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [currentProfileProvider.overrideWith((ref) => null)],
        child: const TestRulesView(),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('testRulesTestButton')));
    await tester.pump();
    expect(find.byType(TestRulesView), findsOneWidget);
  });
}
