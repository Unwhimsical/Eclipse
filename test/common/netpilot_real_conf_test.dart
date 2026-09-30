import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';

const _fixture = '''
[General]
dns-server = 119.29.29.29
skip-proxy = 192.168.0.0/16

[Rule]
AND,((PROTOCOL,UDP),(DEST-PORT,443)),REJECT-NO-DROP
DOMAIN-SUFFIX,example.com,PROXY
FINAL,DIRECT

[Host]
localhost = 127.0.0.1

[URL Rewrite]
^https?://example.com/a https://example.com/b 302
^https?://example.com/c https://example.com/d 302

[MITM]
enable = true
hostname = gs-loc.apple.com,gs-loc-cn.apple.com
''';

void main() {
  test('parses conf with MITM section', () {
    final data = parseConf(_fixture);

    expect(data.isEmpty, isFalse);
    expect(data.rules.isNotEmpty, isTrue);
    expect(data.hosts.isNotEmpty, isTrue);
    expect(data.urlRewrites.length, 2);

    final ruleStrs = data.rules.map((r) => r.toString()).toList();
    expect(
      ruleStrs.any((r) => r.contains('AND') && r.contains('REJECT')),
      isTrue,
    );
    expect(ruleStrs.any((r) => r.contains('MATCH')), isTrue);
    expect(ruleStrs.any((r) => r.contains('NETWORK')), isTrue);
    expect(ruleStrs.any((r) => r.contains('DST-PORT')), isTrue);

    expect(data.hosts['localhost'], '127.0.0.1');
    expect(data.mitm['enable'], 'true');
    final hostname = data.mitm['hostname'] ?? '';
    expect(hostname.contains('gs-loc.apple.com'), isTrue);
    expect(data.general['dns-server'], '119.29.29.29');
    expect(data.general['skip-proxy'], '192.168.0.0/16');
  });
}
