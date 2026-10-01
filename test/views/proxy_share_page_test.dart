import 'package:fl_clash/views/proxy_share/proxy_share.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ProxyShareView renders switch and off tip', (tester) async {
    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: ProxyShareView()),
    );
    await tester.pump();
    expect(find.byType(ProxyShareView), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('ProxyShareView shows address after enabling', (tester) async {
    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: ProxyShareView()),
    );
    await tester.pump();
    expect(find.byIcon(Icons.copy_outlined), findsNothing);
    await tester.tap(find.byType(Switch));
    await tester.pump();
    expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
  });
}
