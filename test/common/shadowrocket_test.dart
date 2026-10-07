import 'dart:convert';

import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart' as yaml;

String _b64(String s) => base64Encode(utf8.encode(s));

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

    test('parses ssr link', () {
      final inner =
          'example.com:8388:origin:aes-256-cfb:plain:${_b64('test-password')}'
          '/?remarks=${_b64('test-ssr')}';
      final proxy = parseShareLink('ssr://${_b64(inner)}');
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'ssr');
      expect(proxy['server'], 'example.com');
      expect(proxy['port'], 8388);
      expect(proxy['cipher'], 'aes-256-cfb');
      expect(proxy['password'], 'test-password');
      expect(proxy['protocol'], 'origin');
      expect(proxy['obfs'], 'plain');
      expect(proxy['name'], 'test-ssr');
    });

    test('returns null for malformed ssr link', () {
      expect(parseShareLink('ssr://${_b64('too:few')}'), isNull);
      expect(parseShareLink('ssr://%%invalid%%'), isNull);
    });

    test('parses ssr link with obfsparam and protoparam', () {
      final inner =
          'example.com:8388:auth_aes128_md5:aes-256-cfb:tls1.2_ticket_auth:${_b64('test-password')}'
          '/?obfsparam=${_b64('obfs-param-value')}'
          '&protoparam=${_b64('proto-param-value')}'
          '&remarks=${_b64('test-ssr-params')}';
      final proxy = parseShareLink('ssr://${_b64(inner)}');
      expect(proxy, isNotNull);
      expect(proxy!['obfs-param'], 'obfs-param-value');
      expect(proxy['protocol-param'], 'proto-param-value');
    });

    test('parses vmess link with ws+tls', () {
      final json = jsonEncode({
        'ps': 'test-vmess',
        'add': 'example.com',
        'port': '443',
        'id': '123e4567-e89b-12d3-a456-426614174000',
        'aid': '0',
        'net': 'ws',
        'host': 'example.com',
        'path': '/ws',
        'tls': 'tls',
      });
      final proxy = parseShareLink('vmess://${_b64(json)}');
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'vmess');
      expect(proxy['server'], 'example.com');
      expect(proxy['port'], 443);
      expect(proxy['uuid'], '123e4567-e89b-12d3-a456-426614174000');
      expect(proxy['tls'], isTrue);
      expect(proxy['network'], 'ws');
      expect(proxy['servername'], 'example.com');
      expect((proxy['ws-opts'] as Map)['path'], '/ws');
    });

    test('parses vmess link with grpc without tls', () {
      final json = jsonEncode({
        'add': 'example.com',
        'port': 80,
        'id': 'uuid',
        'net': 'grpc',
        'path': 'svc',
      });
      final proxy = parseShareLink('vmess://${_b64(json)}');
      expect(proxy, isNotNull);
      expect(proxy!['tls'], isFalse);
      expect(proxy['network'], 'grpc');
      expect((proxy['grpc-opts'] as Map)['grpc-service-name'], 'svc');
      expect(proxy['name'], 'example.com:80');
    });

    test('returns null for malformed vmess link', () {
      expect(parseShareLink('vmess://${_b64('not json')}'), isNull);
      expect(parseShareLink('vmess://${_b64('[]')}'), isNull);
    });

    test('parses vless link with tls', () {
      final proxy = parseShareLink(
        'vless://123e4567-e89b-12d3-a456-426614174000@example.com:443'
        '?security=tls&sni=example.com&fp=chrome&alpn=h2,http/1.1'
        '&type=ws&path=/ws&host=example.com#test-vless',
      );
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'vless');
      expect(proxy['tls'], isTrue);
      expect(proxy['servername'], 'example.com');
      expect(proxy['client-fingerprint'], 'chrome');
      expect(proxy['alpn'], ['h2', 'http/1.1']);
      expect(proxy['network'], 'ws');
      expect(proxy['name'], 'test-vless');
    });

    test('parses vless link with reality', () {
      final proxy = parseShareLink(
        'vless://uuid@example.com:443?security=reality&sni=example.com'
        '&pbk=pubkey&sid=shortid#test',
      );
      expect(proxy, isNotNull);
      expect(proxy!['tls'], isTrue);
      expect((proxy['reality-opts'] as Map)['public-key'], 'pubkey');
      expect((proxy['reality-opts'] as Map)['short-id'], 'shortid');
    });

    test('parses vless link with flow', () {
      final proxy = parseShareLink(
        'vless://uuid@example.com:443?security=tls&flow=xtls-rprx-vision#t',
      );
      expect(proxy, isNotNull);
      expect(proxy!['flow'], 'xtls-rprx-vision');
    });

    test('returns null for malformed vless link', () {
      expect(parseShareLink('vless://no-at-sign-here'), isNull);
    });

    test('parses hysteria2 link', () {
      final proxy = parseShareLink(
        'hysteria2://password@example.com:443?sni=example.com&insecure=1#hy2',
      );
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'hysteria2');
      expect(proxy['server'], 'example.com');
      expect(proxy['password'], 'password');
      expect(proxy['sni'], 'example.com');
      expect(proxy['skip-cert-verify'], isTrue);
      expect(proxy['name'], 'hy2');
    });

    test('parses tuic link', () {
      final proxy = parseShareLink(
        'tuic://myuuid:mypass@example.com:443?sni=example.com#tuic',
      );
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'tuic');
      expect(proxy['uuid'], 'myuuid');
      expect(proxy['password'], 'mypass');
      expect(proxy['sni'], 'example.com');
    });

    test('returns null for link without @ in tuic', () {
      expect(parseShareLink('tuic://example.com:443'), isNull);
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

    test('normalizes granular REJECT actions to safe equivalents', () {
      final data = parseConf('''
[Rule]
DOMAIN-SUFFIX,a.example.com,REJECT-DICT
DOMAIN-SUFFIX,b.example.com,REJECT-ARRAY
DOMAIN-SUFFIX,c.example.com,REJECT-200
DOMAIN-SUFFIX,d.example.com,REJECT-IMG
DOMAIN-SUFFIX,e.example.com,REJECT-TINYGIF
DOMAIN-SUFFIX,f.example.com,REJECT-VIDEO
DOMAIN-SUFFIX,g.example.com,REJECT-DROP
''');
      expect(data.rules, hasLength(7));
      for (final r in data.rules.take(6)) {
        expect(r, endsWith(',REJECT'));
      }
      expect(data.rules[6], endsWith(',REJECT-DROP'));
    });

    test('keeps USER-AGENT as comment instead of dropping', () {
      final data = parseConf('''
[Rule]
USER-AGENT,MyApp*,PROXY
''');
      expect(data.rules, hasLength(1));
      expect(data.rules[0], startsWith('#'));
      expect(data.rules[0], contains('USER-AGENT'));
    });

    test('strips RULE-SET update-interval', () {
      final data = parseConf('''
[Rule]
RULE-SET,https://example.com/rules.txt,PROXY,update-interval=86400
''');
      expect(data.rules, hasLength(1));
      expect(data.rules[0], 'RULE-SET,https://example.com/rules.txt,PROXY');
      expect(data.rules[0], isNot(contains('update-interval')));
    });

    test('keeps USER-AGENT as comment (not silently dropped)', () {
      final data = parseConf('''
[Rule]
USER-AGENT,WeChat*,DIRECT
DOMAIN-SUFFIX,example.com,PROXY
''');
      expect(data.rules, hasLength(2));
      expect(data.rules[0], startsWith('#'));
      expect(data.rules[0], contains('USER-AGENT'));
      expect(data.rules[1], 'DOMAIN-SUFFIX,example.com,PROXY');
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

    test('parses all proxy types', () {
      final data = parseConf('''
[Proxy]
n-ssr = ssr, example.com, 8388, aes-256-cfb, pass, origin, plain
n-vmess = vmess, example.com, 443, uuid-1, ws, /ws, tls, example.com
n-vless = vless, example.com, 443, uuid-2, ws, /ws, xtls, example.com, xtls-rprx-vision
n-hy2 = hysteria2, example.com, 443, pass, example.com
n-tuic = tuic, example.com, 443, uuid-3, pass, example.com
n-http = http, example.com, 8080, user, pass, tls
n-http-noauth = http, example.com, 8080
n-socks = socks5, example.com, 1080, user, pass
n-unknown = wireguard, example.com, 51820
''');
      expect(data.proxies, hasLength(8));
      final byName = {for (final p in data.proxies) p['name']: p};
      expect(byName['n-ssr']!['type'], 'ssr');
      expect(byName['n-ssr']!['protocol'], 'origin');
      expect(byName['n-vmess']!['type'], 'vmess');
      expect(byName['n-vmess']!['tls'], isTrue);
      expect(byName['n-vmess']!['network'], 'ws');
      expect(byName['n-vless']!['flow'], 'xtls-rprx-vision');
      expect(byName['n-hy2']!['type'], 'hysteria2');
      expect(byName['n-tuic']!['type'], 'tuic');
      expect(byName['n-tuic']!['uuid'], 'uuid-3');
      expect(byName['n-http']!['type'], 'http');
      expect(byName['n-http']!['username'], 'user');
      expect(byName['n-http']!['tls'], isTrue);
      expect(byName['n-http-noauth']!['tls'], isFalse);
      expect(byName['n-http-noauth']!.containsKey('username'), isFalse);
      expect(byName['n-socks']!['type'], 'socks5');
      expect(byName['n-socks']!['password'], 'pass');
      expect(byName.containsKey('n-unknown'), isFalse);
    });

    test('parses vmess over-tls and grpc variants', () {
      final data = parseConf('''
[Proxy]
a = vmess, example.com, 443, uuid, grpc, svc, over-tls=true, example.com
b = vmess, example.com, 80, uuid, tcp
''');
      final byName = {for (final p in data.proxies) p['name']: p};
      expect(byName['a']!['tls'], isTrue);
      expect(byName['a']!['network'], 'grpc');
      expect(byName['b']!['network'], 'tcp');
      expect(byName['b']!['tls'], isFalse);
    });

    test('parses vless plain and ws variants', () {
      final data = parseConf('''
[Proxy]
a = vless, example.com, 443, uuid, tcp, , tls
b = vless, example.com, 80, uuid
''');
      final byName = {for (final p in data.proxies) p['name']: p};
      expect(byName['a']!['tls'], isTrue);
      expect(byName['a']!['servername'], 'example.com');
      expect(byName['b']!['tls'], isFalse);
    });

    test('parses proxy group types', () {
      final data = parseConf('''
[Proxy Group]
SEL = select, n1, n2
AUTO = url-test, n1, n2
FB = fallback, n1
LB = load-balance, n1, n2
BAD = bogus-type, n1
''');
      expect(data.proxyGroups, hasLength(4));
      final byName = {for (final g in data.proxyGroups) g['name']: g};
      expect(byName['SEL']!['type'], 'select');
      expect(byName['AUTO']!['type'], 'url-test');
      expect(byName['AUTO']!['url'], isNotEmpty);
      expect(byName['AUTO']!['interval'], 300);
      expect(byName['FB']!['type'], 'fallback');
      expect(byName['LB']!['type'], 'load-balance');
      expect(byName.containsKey('BAD'), isFalse);
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

    test('parses author metadata', () {
      final module = parseSgmodule('#!name=Test\n#!author=John Doe\n[Rule]\n');
      expect(module.author, 'John Doe');
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
        tunExcludedRoutes: ['10.0.0.0/8'],
        ipv6Enabled: false,
      );
      final doc = yaml.loadYaml(text) as Map;
      // skip-proxy stays on the TUN path: no DIRECT rules are forced.
      final rules = doc['rules'] as List;
      expect(rules.where((r) => (r as String).endsWith(',DIRECT')), isEmpty);
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

    test('uses provided groups, rules and tun include routes', () {
      final text = buildClashConfigFromProxies(
        proxies: [
          {'name': 'node1', 'type': 'ss'},
        ],
        proxyGroups: [
          {
            'name': 'AUTO',
            'type': 'url-test',
            'proxies': ['node1'],
          },
        ],
        rules: ['DOMAIN-SUFFIX,example.com,AUTO'],
        tunIncludedRoutes: ['192.168.0.0/16'],
        alwaysRealIp: true,
        dnsServers: ['8.8.8.8'],
        groupName: 'CUSTOM',
      );
      final doc = yaml.loadYaml(text) as Map;
      expect((doc['proxy-groups'] as List).first['name'], 'AUTO');
      expect(doc['rules'], ['DOMAIN-SUFFIX,example.com,AUTO']);
      expect((doc['tun'] as Map)['route-include-address'], ['192.168.0.0/16']);
      expect((doc['dns'] as Map).containsKey('respect-rules'), isFalse);
    });

    test('omits dns and tun sections when empty', () {
      final text = buildClashConfigFromProxies(
        proxies: [
          {'name': 'node1', 'type': 'ss'},
        ],
      );
      final doc = yaml.loadYaml(text) as Map;
      expect(doc.containsKey('dns'), isFalse);
      expect(doc.containsKey('tun'), isFalse);
      expect(doc.containsKey('ipv6'), isFalse);
    });

    test('proxy-less conf yields a safe rule-only config', () {
      final text = buildClashConfigFromProxies(proxies: const []);
      final doc = yaml.loadYaml(text) as Map;
      expect(doc['proxies'], isEmpty);
      expect(doc.containsKey('proxy-groups'), isFalse);
      expect(doc['rules'], ['MATCH,DIRECT']);
    });

    test('proxy-less conf keeps its own rules without a group', () {
      final text = buildClashConfigFromProxies(
        proxies: const [],
        rules: ['DOMAIN-SUFFIX,example.com,REJECT', 'MATCH,DIRECT'],
        dnsServers: ['8.8.8.8'],
      );
      final doc = yaml.loadYaml(text) as Map;
      expect(doc.containsKey('proxy-groups'), isFalse);
      expect(doc['rules'], [
        'DOMAIN-SUFFIX,example.com,REJECT',
        'MATCH,DIRECT',
      ]);
      expect((doc['dns'] as Map)['nameserver'], ['8.8.8.8']);
    });

    test('drops parser placeholder comment lines from rules', () {
      final text = buildClashConfigFromProxies(
        proxies: [
          {'name': 'node1', 'type': 'ss'},
        ],
        rules: [
          '# USER-AGENT not supported by Clash: USER-AGENT,foo,REJECT',
          'DOMAIN-SUFFIX,example.com,REJECT',
        ],
      );
      final doc = yaml.loadYaml(text) as Map;
      expect(doc['rules'], ['DOMAIN-SUFFIX,example.com,REJECT']);
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

    test('parses tun-included-routes', () {
      final conf = parseConf('''
[General]
tun-included-routes = 192.168.1.0/24, 10.0.0.0/8
''');
      expect(conf.tunIncludedRoutes, ['192.168.1.0/24', '10.0.0.0/8']);
    });

    test('returns empty for missing tun routes', () {
      final conf = parseConf('[General]\n');
      expect(conf.tunIncludedRoutes, isEmpty);
      expect(conf.tunExcludedRoutes, isEmpty);
    });

    test('parses private-ip-answer', () {
      expect(parseConf('[General]\n').privateIpAnswer, isTrue);
      expect(
        parseConf('[General]\nprivate-ip-answer = false\n').privateIpAnswer,
        isFalse,
      );
      expect(
        parseConf('[General]\nprivate-ip-answer = 0\n').privateIpAnswer,
        isFalse,
      );
      expect(
        parseConf('[General]\nprivate-ip-answer = no\n').privateIpAnswer,
        isFalse,
      );
      expect(
        parseConf('[General]\nprivate-ip-answer = true\n').privateIpAnswer,
        isTrue,
      );
    });

    test('parses Host section', () {
      final conf = parseConf('''
[Host]
example.com = 1.2.3.4
*.example.org = 5.6.7.8, 9.10.11.12
''');
      expect(conf.hosts, {
        'example.com': '1.2.3.4',
        '*.example.org': '5.6.7.8, 9.10.11.12',
      });
    });

    test('parses URL Rewrite section', () {
      final conf = parseConf('''
[URL Rewrite]
^https?://example.com/ad - reject
^https?://example.org/(.*) https://example.net/\$1 302
''');
      expect(conf.urlRewrites, hasLength(2));
      expect(conf.urlRewrites[0], contains('reject'));
      expect(conf.urlRewrites[1], contains('302'));
    });

    test('parses Header Rewrite section', () {
      final conf = parseConf('''
[Header Rewrite]
^https?://example.com header-add X-Test 1
^https?://example.org header-del X-Remove
''');
      expect(conf.headerRewrites, hasLength(2));
      expect(conf.headerRewrites[0], contains('header-add'));
      expect(conf.headerRewrites[1], contains('header-del'));
    });

    test('isEmpty accounts for hosts and rewrites', () {
      expect(parseConf('[General]\n').isEmpty, isTrue);
      expect(parseConf('[Host]\na = b\n').isEmpty, isFalse);
      expect(parseConf('[URL Rewrite]\na b\n').isEmpty, isFalse);
      expect(parseConf('[Header Rewrite]\na b\n').isEmpty, isFalse);
    });
  });

  group('parseShareLink edge cases', () {
    test('parses ss with IPv6 host', () {
      final proxy = parseShareLink(
        'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@[::1]:8388#test-ipv6',
      );
      expect(proxy, isNotNull);
      expect(proxy!['server'], '::1');
      expect(proxy['port'], 8388);
    });

    test('parses ss with fully base64-encoded URI', () {
      final inner = 'aes-256-gcm:password@example.com:8388';
      final proxy = parseShareLink('ss://${_b64(inner)}#test-b64');
      expect(proxy, isNotNull);
      expect(proxy!['type'], 'ss');
      expect(proxy['server'], 'example.com');
      expect(proxy['cipher'], 'aes-256-gcm');
    });

    test('parses ss with plugin params', () {
      final proxy = parseShareLink(
        'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388'
        '?plugin=obfs-local%3Bobfs%3Dhttp#test-plugin',
      );
      expect(proxy, isNotNull);
      expect(proxy!['plugin'], isNotNull);
    });

    test('rejects ss with invalid userinfo', () {
      expect(parseShareLink('ss://bm9jb2xvbg==@example.com:8388'), isNull);
    });

    test('rejects ss with empty host', () {
      expect(parseShareLink('ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@:8388'), isNull);
    });
  });

  group('conf / sgmodule detection', () {
    const pureRuleConf = '''
[General]
bypass-system = true

[Rule]
DOMAIN-SUFFIX,example.com,PROXY
IP-CIDR,10.0.0.0/8,DIRECT

[Host]
example.com = 1.2.3.4

[MITM]
enable = true
hostname = %APPEND%example.com
''';

    const sgmodule = '''
#!name=AdBlock

[Rule]
DOMAIN-SUFFIX,ads.example.com,REJECT

[MITM]
hostname = %APPEND%ads.example.com
''';

    const clashYaml = '''
proxies:
  - name: test
    type: ss
    server: example.com
    port: 8388
''';

    test('detects pure-rule conf without [Proxy]', () {
      expect(isShadowrocketConfText(pureRuleConf), isTrue);
      expect(isSgmoduleText(pureRuleConf), isFalse);
    });

    test('detects conf with [Proxy] section', () {
      expect(
        isShadowrocketConfText('[Proxy]\ntest = ss, example.com, 8388\n'),
        isTrue,
      );
    });

    test('detects sgmodule by metadata header', () {
      expect(isSgmoduleText(sgmodule), isTrue);
    });

    test('sgmodule wins over conf detection', () {
      // Modules also contain [Rule]; callers must check sgmodule first.
      expect(isShadowrocketConfText(sgmodule), isTrue);
      expect(isSgmoduleText(sgmodule), isTrue);
    });

    test('rejects Clash YAML', () {
      expect(isShadowrocketConfText(clashYaml), isFalse);
      expect(isSgmoduleText(clashYaml), isFalse);
    });

    test('rejects share links and random text', () {
      expect(
        isShadowrocketConfText('ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@h:8388'),
        isFalse,
      );
      expect(isSgmoduleText('just some text\nwith [brackets]'), isFalse);
    });
  });
}
