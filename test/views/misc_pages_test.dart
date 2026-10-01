import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/clipboard_watcher/clipboard_watcher.dart';
import 'package:fl_clash/views/delay_test/delay_test.dart';
import 'package:fl_clash/views/permissions/permissions.dart';
import 'package:fl_clash/views/tunnel/tunnel.dart';
import 'package:fl_clash/views/tunnel/udp_stun.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('PermissionsView renders permission notes', (tester) async {
    await tester.pumpWidget(const TestApp(child: PermissionsView()));
    await tester.pump();
    expect(find.byType(PermissionsView), findsOneWidget);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.byIcon(Icons.content_paste_outlined), findsOneWidget);
  });

  testWidgets('TunnelRoutesView shows no-profile hint without profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [currentProfileProvider.overrideWith((ref) => null)],
        child: const TunnelRoutesView(),
      ),
    );
    await tester.pump();
    expect(find.byType(TunnelRoutesView), findsOneWidget);
  });

  testWidgets('ClipboardLinkWatcher renders child', (tester) async {
    String? detected;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: ClipboardLinkWatcher(
          onLinkDetected: (link) async => detected = link,
          child: const Text('child'),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ClipboardLinkWatcher), findsOneWidget);
    expect(find.text('child'), findsOneWidget);
    expect(detected, isNull);
  });

  testWidgets('UdpStunView renders switches', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [currentProfileProvider.overrideWith((ref) => null)],
        child: const UdpStunView(),
      ),
    );
    await tester.pump();
    expect(find.byType(UdpStunView), findsOneWidget);
    expect(find.byType(Switch), findsWidgets);
  });

  testWidgets('DelayTestView renders form', (tester) async {
    await tester.pumpWidget(
      const TestApp(wrapInProviderScope: true, child: DelayTestView()),
    );
    await tester.pump();
    expect(find.byType(DelayTestView), findsOneWidget);
  });
}
