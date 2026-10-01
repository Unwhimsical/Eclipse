import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/home/node_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_app.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

const _proxyName = 'hk-node-01';

Group _group({String? testUrl}) =>
    Group(type: GroupType.Selector, name: 'PROXY', testUrl: testUrl);

Proxy _proxy() => const Proxy(name: _proxyName, type: 'ss');

TrackerInfo _connection({required String chain}) => TrackerInfo(
  id: 'conn-1',
  start: DateTime(2026, 1, 1),
  metadata: const Metadata(
    host: 'example.com',
    destinationPort: '443',
    sourceIP: '192.168.1.2',
    sourcePort: '54321',
  ),
  chains: [chain],
  rule: 'PROXY',
  rulePayload: '',
  upload: 1024,
  download: 2048,
  uploadSpeed: 100,
  downloadSpeed: 200,
);

Future<void> _pumpPage(
  WidgetTester tester, {
  List<TrackerInfo> connections = const [],
  int? delay,
  String? testUrl,
}) async {
  final core = _MockCoreHandlerInterface();
  when(() => core.getConnections()).thenAnswer((_) async => connections);
  await tester.pumpWidget(
    TestApp(
      wrapInProviderScope: true,
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        delayProvider(
          proxyName: _proxyName,
          testUrl: testUrl,
        ).overrideWithValue(delay),
        delayTestPendingProvider(
          proxyName: _proxyName,
          testUrl: testUrl,
        ).overrideWithValue(false),
      ],
      child: NodeDetailPage(
        proxy: _proxy(),
        group: _group(testUrl: testUrl),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NodeDetailPage renders proxy info without connections', (
    tester,
  ) async {
    await _pumpPage(tester);
    expect(find.byType(NodeDetailPage), findsOneWidget);
    expect(find.text(_proxyName), findsWidgets);
    expect(find.text('PROXY'), findsWidgets);
  });

  testWidgets('NodeDetailPage shows delay when measured', (tester) async {
    await _pumpPage(tester, delay: 120);
    expect(find.text('120 ms'), findsOneWidget);
  });

  testWidgets('NodeDetailPage shows timeout delay', (tester) async {
    await _pumpPage(tester, delay: 0);
    expect(find.text('Timeout'), findsOneWidget);
  });

  testWidgets('NodeDetailPage aggregates connection traffic and addresses', (
    tester,
  ) async {
    await _pumpPage(tester, connections: [_connection(chain: _proxyName)]);
    expect(find.text('example.com:443'), findsOneWidget);
    expect(find.text('192.168.1.2:54321'), findsOneWidget);
  });

  testWidgets('NodeDetailPage ignores connections of other chains', (
    tester,
  ) async {
    await _pumpPage(tester, connections: [_connection(chain: 'other-node')]);
    expect(find.text('example.com:443'), findsNothing);
  });
}
