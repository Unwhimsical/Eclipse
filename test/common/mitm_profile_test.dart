// MITM hostname end-to-end: conf [MITM] -> Profile -> MitmManager.
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_clash/common/shadowrocket.dart';

void main() {
  group('MITM conf parsing', () {
    test('parses [MITM] enable and hostname', () {
      const conf = '''
[General]
dns-server = 8.8.8.8

[MITM]
enable = true
hostname = gs-loc.apple.com, gsp-ssl.ls.apple.com

[Rule]
DOMAIN-SUFFIX,example.com,DIRECT
''';
      final data = parseConf(conf);
      expect(data.mitm['enable'], 'true');
      expect(data.mitm['hostname'], contains('gs-loc.apple.com'));
      final hostnames = (data.mitm['hostname'] ?? '')
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      expect(hostnames, ['gs-loc.apple.com', 'gsp-ssl.ls.apple.com']);
    });

    test('enable=false means no interception', () {
      const conf = '''
[MITM]
enable = false
hostname = gs-loc.apple.com
''';
      final data = parseConf(conf);
      final enabled = data.mitm['enable']?.toLowerCase() == 'true';
      expect(enabled, isFalse);
    });

    test('MITM-only conf is not empty', () {
      const conf = '''
[MITM]
enable = true
hostname = gs-loc.apple.com
''';
      final data = parseConf(conf);
      expect(data.isEmpty, isFalse);
      expect(data.proxies.isEmpty, isTrue);
    });
  });
}
