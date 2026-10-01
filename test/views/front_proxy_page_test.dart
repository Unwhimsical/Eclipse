import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/front_proxy/front_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

ClashConfig _config() {
  return const ClashConfig(
    proxies: [
      Proxy(name: 'http-node', type: 'http'),
      Proxy(name: 'socks-node', type: 'socks5'),
      Proxy(name: 'ss-node', type: 'ss'),
      Proxy(name: 'trojan-node', type: 'trojan'),
    ],
  );
}

void main() {
  test('isFrontProxyCandidate only allows http and socks5', () {
    expect(isFrontProxyCandidate(const Proxy(name: 'a', type: 'http')), isTrue);
    expect(
      isFrontProxyCandidate(const Proxy(name: 'b', type: 'socks5')),
      isTrue,
    );
    expect(isFrontProxyCandidate(const Proxy(name: 'c', type: 'HTTP')), isTrue);
    expect(isFrontProxyCandidate(const Proxy(name: 'd', type: 'ss')), isFalse);
    expect(
      isFrontProxyCandidate(const Proxy(name: 'e', type: 'vmess')),
      isFalse,
    );
  });

  testWidgets('FrontProxyView lists http/socks5 nodes only', (tester) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [currentProfileProvider.overrideWith((ref) => null)],
        child: FrontProxyView(testConfig: _config()),
      ),
    );
    await tester.pump();
    expect(find.byType(FrontProxyView), findsOneWidget);
    expect(find.text('http-node'), findsOneWidget);
    expect(find.text('socks-node'), findsOneWidget);
    expect(find.text('ss-node'), findsNothing);
    expect(find.text('trojan-node'), findsNothing);
  });

  testWidgets('FrontProxyView shows empty hint without candidates', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        overrides: [currentProfileProvider.overrideWith((ref) => null)],
        child: const FrontProxyView(testConfig: ClashConfig()),
      ),
    );
    await tester.pump();
    expect(find.byType(FrontProxyView), findsOneWidget);
    expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
  });
}
