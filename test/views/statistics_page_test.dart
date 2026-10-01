import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/views/statistics/statistics.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

TrackerInfo _info({
  required String id,
  required String rule,
  required List<String> chains,
  int upload = 0,
  int download = 0,
}) {
  return TrackerInfo(
    id: id,
    upload: upload,
    download: download,
    start: DateTime(2026, 10, 1),
    metadata: const Metadata(host: 'example.com', network: 'tcp'),
    chains: chains,
    rule: rule,
    rulePayload: '',
  );
}

void main() {
  test('categorizeConnection buckets by chains and rule', () {
    expect(
      categorizeConnection(_info(id: '1', rule: 'DomainSuffix', chains: ['g'])),
      TrafficCategory.proxy,
    );
    expect(
      categorizeConnection(_info(id: '2', rule: 'DomainSuffix', chains: [])),
      TrafficCategory.direct,
    );
    expect(
      categorizeConnection(_info(id: '3', rule: 'REJECT-DICT', chains: [])),
      TrafficCategory.reject,
    );
    expect(
      categorizeConnection(_info(id: '4', rule: '', chains: [])),
      TrafficCategory.other,
    );
  });

  test('aggregateTraffic sums upload and download per bucket', () {
    final result = aggregateTraffic([
      _info(
        id: '1',
        rule: 'DomainSuffix',
        chains: ['g'],
        upload: 10,
        download: 20,
      ),
      _info(
        id: '2',
        rule: 'DomainSuffix',
        chains: ['g'],
        upload: 5,
        download: 5,
      ),
      _info(id: '3', rule: 'DomainSuffix', chains: [], upload: 7, download: 3),
    ]);
    expect(result[TrafficCategory.proxy]!.upload, 15);
    expect(result[TrafficCategory.proxy]!.download, 25);
    expect(result[TrafficCategory.direct]!.total, 10);
    expect(result[TrafficCategory.reject]!.total, 0);
  });

  testWidgets('StatisticsView renders with injected connections', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: StatisticsView(
          connectionsReader: () async => [
            _info(
              id: '1',
              rule: 'DomainSuffix',
              chains: ['proxy-group'],
              upload: 100,
              download: 200,
            ),
          ],
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(StatisticsView), findsOneWidget);
    expect(find.text('example.com'), findsOneWidget);
  });
}
