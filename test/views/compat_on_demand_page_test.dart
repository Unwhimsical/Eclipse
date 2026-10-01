import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/compat_mode/compat_mode.dart';
import 'package:fl_clash/views/on_demand/on_demand_extras.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FeatureFlags bool roundtrip', () async {
    await FeatureFlags.setBool(FeatureFlags.compatibilityMode, true);
    expect(await FeatureFlags.getBool(FeatureFlags.compatibilityMode), isTrue);
    await FeatureFlags.setBool(FeatureFlags.compatibilityMode, false);
    expect(await FeatureFlags.getBool(FeatureFlags.compatibilityMode), isFalse);
  });

  test('FeatureFlags string roundtrip', () async {
    await FeatureFlags.setString(FeatureFlags.delayTestUrl, 'https://x.test');
    expect(
      await FeatureFlags.getString(FeatureFlags.delayTestUrl),
      'https://x.test',
    );
    await FeatureFlags.setString(FeatureFlags.delayTestUrl, null);
    expect(await FeatureFlags.getString(FeatureFlags.delayTestUrl), isNull);
  });

  testWidgets('CompatModeView renders switch', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [currentProfileProvider.overrideWith((ref) => null)],
        child: const CompatModeView(),
      ),
    );
    await tester.pump();
    expect(find.byType(CompatModeView), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });

  testWidgets('OnDemandExtrasView renders three switches', (tester) async {
    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: OnDemandExtrasView()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(OnDemandExtrasView), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(3));
  });
}
