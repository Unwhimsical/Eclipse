import 'package:fl_clash/common/shadowrocket.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart' as yaml;

void main() {
  group('parseShareLink', () {
    test('parses ss link', () {
      final proxy = parseShareLink(
        'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388#test-ss',
      );
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'ss');
      expect(proxy['server'], 'example.com');
      expect(proxy['port'], 8388);
      expect(proxy['name'], 'test-ss');
    });

    test('returns null for garbage input', () {
      expect(parseShareLink('not a link'), isNull);
      expect(parseShareLink(''), isNull);
      expect(parseShareLink('http://example.com'), isNull);
    });

    test('parses trojan link', () {
      final proxy = parseShareLink(
        'trojan://password@example.com:443#test-trojan',
      );
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'trojan');
      expect(proxy['server'], 'example.com');
      expect(proxy['port'], 443);
    });
  });

  group('parseConf', () {
    const sample = '''
[General]
dns-server = 8.8.8.8, 1.1.1.1
fallback-dns-server = 9.9.9.9
skip-proxy = 192.168.0.0/16

[Proxy]
node1 = ss, example.com, 8388, aes-256-gcm, password
node2 = trojan, example.org, 443, secret

[Proxy Group]
PROXY = select, node1, node2

[Rule]
DOMAIN-SUFFIX,example.com,PROXY
FINAL,DIRECT
''';

    test('parses general section', () {
      final data = parseConf(sample);
      expect(data.general['dns-server'], '8.8.8.8, 1.1.1.1');
      expect(data.general['fallback-dns-server'], '9.9.9.9');
      expect(data.general['skip-proxy'], '192.168.0.0/16');
    });

    test('exposes dns servers', () {
      final data = parseConf(sample);
      expect(data.dnsServers, ['8.8.8.8', '1.1.1.1', '9.9.9.9']);
    });

    test('parses proxies', () {
      final data = parseConf(sample);
      expect(data.proxies, hasLength(2));
      expect(data.proxies[0]['name'], 'node1');
      expect(data.proxies[0]['type'], 'ss');
      expect(data.proxies[1]['name'], 'node2');
      expect(data.proxies[1]['type'], 'trojan');
    });

    test('parses proxy groups', () {
      final data = parseConf(sample);
      expect(data.proxyGroups, hasLength(1));
      expect(data.proxyGroups[0]['name'], 'PROXY');
    });

    test('normalizes FINAL to MATCH', () {
      final data = parseConf(sample);
      expect(data.rules, contains('DOMAIN-SUFFIX,example.com,PROXY'));
      expect(data.rules, contains('MATCH,DIRECT'));
      expect(data.rules.any((r) => r.startsWith('FINAL,')), isFalse);
    });

    test('normalizes PROTOCOL, DEST-PORT and REJECT-NO-DROP', () {
      final data = parseConf('''
[Rule]
AND,((PROTOCOL,UDP),(DEST-PORT,443)),REJECT-NO-DROP
''');
      expect(data.rules, hasLength(1));
      expect(data.rules[0], contains('NETWORK,UDP'));
      expect(data.rules[0], contains('DST-PORT,443'));
      expect(data.rules[0], contains('REJECT'));
      expect(data.rules[0], isNot(contains('REJECT-NO-DROP')));
    });

    test('drops USER-AGENT rules', () {
      final data = parseConf('''
[Rule]
USER-AGENT,WeChat*,DIRECT
DOMAIN-SUFFIX,example.com,PROXY
''');
      expect(data.rules, hasLength(1));
      expect(data.rules[0], 'DOMAIN-SUFFIX,example.com,PROXY');
    });

    test('skips comments and empty lines', () {
      final data = parseConf('''
# a comment
; another comment

[Rule]
DOMAIN-SUFFIX,example.com,PROXY
''');
      expect(data.rules, hasLength(1));
      expect(data.isEmpty, isFalse);
    });

    test('empty input yields empty data', () {
      expect(parseConf('').isEmpty, isTrue);
    });
  });

  group('parseSgmodule', () {
    const sample = '''
#!name=Test Module
#!desc=A test module
[Rule]
DOMAIN-SUFFIX,ads.example.com,REJECT
[Host]
example.com = 1.2.3.4
[URL Rewrite]
^https://example.com/ad - reject
[Header Rewrite]
^https://example.com/ header-del "X-Unwanted"
^https://example.com/ header-add "X-Custom: value"
[Script]
test.js = type=http-response,pattern=^https://example.com,requires-body=1,script-path=https://example.com/test.js
[MITM]
hostname = %APPEND%,example.com,*.example.org
''';

    test('parses metadata', () {
      final module = parseSgmodule(sample);
      expect(module.name, 'Test Module');
      expect(module.desc, 'A test module');
    });

    test('parses rules, hosts, rewrites and scripts', () {
      final module = parseSgmodule(sample);
      expect(module.rules, ['DOMAIN-SUFFIX,ads.example.com,REJECT']);
      expect(module.hosts, {'example.com': '1.2.3.4'});
      expect(module.urlRewrites, hasLength(1));
      expect(module.headerRewrites, hasLength(2));
      expect(module.scripts, hasLength(1));
      expect(module.needsMitm, isTrue);
    });

    test('parses header rewrite lines', () {
      final parsed = parseHeaderRewriteLine(
        '^https://example.com/ header-del "X-Unwanted"',
      );
      expect(parsed, isNotNull);
      expect(parsed!.pattern, '^https://example.com/');
      expect(parsed.action, 'header-del');
      expect(parsed.args, ['X-Unwanted']);

      final add = parseHeaderRewriteLine(
        '^https://example.com/ header-add "X-Custom: value"',
      );
      expect(add!.action, 'header-add');
      expect(add.args, ['X-Custom: value']);

      expect(parseHeaderRewriteLine('garbage line'), isNull);
    });

    test('skips %APPEND% in mitm hostnames', () {
      final module = parseSgmodule(sample);
      expect(module.mitmHostnames, contains('example.com'));
      expect(module.mitmHostnames, contains('*.example.org'));
      expect(module.mitmHostnames.any((h) => h.startsWith('%')), isFalse);
    });

    test('empty module is empty', () {
      expect(parseSgmodule('').isEmpty, isTrue);
    });
  });

  group('buildClashConfigFromProxies', () {
    test('builds valid yaml with defaults', () {
      final text = buildClashConfigFromProxies(
        proxies: [
          {'name': 'node1', 'type': 'ss'},
        ],
      );
      final doc = yaml.loadYaml(text) as Map;
      expect((doc['proxies'] as List), hasLength(1));
      expect((doc['proxy-groups'] as List).first['name'], 'PROXY');
      expect(doc['rules'], ['MATCH,PROXY']);
    });

    test('includes dns when servers given', () {
      final text = buildClashConfigFromProxies(
        proxies: [
          {'name': 'node1', 'type': 'ss'},
        ],
        dnsServers: ['8.8.8.8'],
      );
      final doc = yaml.loadYaml(text) as Map;
      expect((doc['dns'] as Map)['nameserver'], ['8.8.8.8']);
    });

    test('wires general params into clash config', () {
      final text = buildClashConfigFromProxies(
        proxies: [
          {'name': 'node1', 'type': 'ss'},
        ],
        dnsServers: ['8.8.8.8'],
        directDnsServers: ['114.114.114.114'],
        skipProxy: ['example.com', '192.168.0.0/16'],
        tunExcludedRoutes: ['10.0.0.0/8'],
        ipv6Enabled: false,
      );
      final doc = yaml.loadYaml(text) as Map;
      // skip-proxy becomes DIRECT rules prepended
      final rules = doc['rules'] as List;
      expect(rules[0], 'DOMAIN-SUFFIX,example.com,DIRECT');
      expect(rules[1], 'IP-CIDR,192.168.0.0/16,DIRECT');
      // dns
      final dns = doc['dns'] as Map;
      expect(dns['direct-nameserver'], ['114.114.114.114']);
      expect(dns['ipv6'], false);
      // tun
      final tun = doc['tun'] as Map;
      expect(tun['route-exclude-address'], ['10.0.0.0/8']);
      // top-level ipv6
      expect(doc['ipv6'], false);
    });
  });

  group('ConfData general getters', () {
    test('parses general params', () {
      final conf = parseConf('''
[General]
dns-server = 8.8.8.8, 1.1.1.1
direct-dns-server = 114.114.114.114
skip-proxy = example.com, 192.168.0.0/16
tun-excluded-routes = 10.0.0.0/8
ipv6 = false
prefer-ipv6 = true
always-real-ip = true
include = https://example.com/extra.conf
''');
      expect(conf.dnsServers, ['8.8.8.8', '1.1.1.1']);
      expect(conf.directDnsServers, ['114.114.114.114']);
      expect(conf.skipProxy, ['example.com', '192.168.0.0/16']);
      expect(conf.tunExcludedRoutes, ['10.0.0.0/8']);
      expect(conf.ipv6Enabled, isFalse);
      expect(conf.preferIpv6, isTrue);
      expect(conf.alwaysRealIp, isTrue);
      expect(conf.includeUrl, 'https://example.com/extra.conf');
    });
  });
}
