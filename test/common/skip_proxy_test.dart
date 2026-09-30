import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('skip-proxy', () {
    test('parses domains and CIDRs from [General]', () {
      const content = '''
[General]
skip-proxy = example.com, 192.168.0.0/16

[Rule]
MATCH,PROXY
''';
      final conf = parseConf(content);
      expect(conf.skipProxy, ['example.com', '192.168.0.0/16']);
    });

    test('buildClashConfigFromProxies generates no DIRECT rules', () {
      final yaml = buildClashConfigFromProxies(
        proxies: [
          {'name': 'p1', 'type': 'ss', 'server': '1.2.3.4', 'port': 8388},
        ],
        rules: ['MATCH,PROXY'],
      );
      expect(yaml, isNot(contains('DIRECT')));
      expect(yaml, contains('MATCH,PROXY'));
    });

    test('tun-excluded-routes still map to route-exclude-address', () {
      final yaml = buildClashConfigFromProxies(
        proxies: [
          {'name': 'p1', 'type': 'ss', 'server': '1.2.3.4', 'port': 8388},
        ],
        tunExcludedRoutes: ['192.168.0.0/16'],
      );
      expect(yaml, contains('route-exclude-address'));
      expect(yaml, contains('192.168.0.0/16'));
    });
  });
}
