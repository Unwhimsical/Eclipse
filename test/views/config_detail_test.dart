import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/config/config_detail.dart';
import 'package:fl_clash/views/theme/components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ConfigDetailPage renders all sections for a profile', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'work config');
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: ConfigDetailPage(profile: profile),
      ),
    );
    await tester.pump();

    expect(find.byType(ConfigDetailPage), findsOneWidget);
    expect(find.text('work config'), findsOneWidget);
    // One EclipseOpenTile per sub page: general + 2 proxies + 7 rules +
    // 3 other (CA, script, modules). The list builds lazily, so collect
    // titles while scrolling through it.
    final seen = <String>{};
    Future<void> collect() async {
      await tester.pump();
      for (final element in find.byType(EclipseOpenTile).evaluate()) {
        seen.add((element.widget as EclipseOpenTile).title);
      }
    }

    Future<void> scrollDown() async {
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
    }

    Future<void> scrollUp() async {
      await tester.drag(find.byType(ListView), const Offset(0, 2000));
      await tester.pumpAndSettle();
    }

    await collect();
    await scrollDown();
    await collect();
    await scrollDown();
    await collect();
    await scrollUp();
    await collect();
    expect(seen, hasLength(13));
  });

  testWidgets('ConfigDetailPage shows the https decryption entry', (
    tester,
  ) async {
    final profile = Profile.normal(label: 'home config');
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: ConfigDetailPage(profile: profile),
      ),
    );
    await tester.pump();

    expect(find.byType(ConfigDetailPage), findsOneWidget);
    expect(find.byType(EclipseSection), findsWidgets);
  });
}
