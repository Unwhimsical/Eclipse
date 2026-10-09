import 'package:fl_clash/common/proxy_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('proxyToShareLink', () {
    test('serializes a vless proxy', () {
      final link = proxyToShareLink({
        'type': 'vless',
        'name': 'us-1',
        'server': 'example.com',
        'port': 443,
        'uuid': '11111111-2222-3333-4444-555555555555',
        'tls': true,
        'sni': 'example.com',
        'network': 'ws',
        'ws-opts': {'path': '/ws'},
      });
      expect(link, isNotNull);
      expect(link, startsWith('vless://11111111-2222-3333-4444-555555555555@'));
      expect(link, contains('example.com:443'));
      expect(link, contains('security=tls'));
      expect(link, contains('type=ws'));
    });

    test('serializes a vmess proxy', () {
      final link = proxyToShareLink({
        'type': 'vmess',
        'name': 'vm',
        'server': 'example.com',
        'port': 443,
        'uuid': '11111111-2222-3333-4444-555555555555',
        'alterId': 0,
        'cipher': 'auto',
        'tls': true,
      });
      expect(link, isNotNull);
      expect(link, startsWith('vmess://'));
    });

    test('serializes a shadowsocks proxy', () {
      final link = proxyToShareLink({
        'type': 'ss',
        'name': 'ss',
        'server': 'example.com',
        'port': 8388,
        'cipher': 'aes-256-gcm',
        'password': 'secret',
      });
      expect(link, isNotNull);
      expect(link, startsWith('ss://'));
      expect(link, contains('example.com:8388'));
    });

    test('serializes a trojan proxy', () {
      final link = proxyToShareLink({
        'type': 'trojan',
        'name': 'tj',
        'server': 'example.com',
        'port': 443,
        'password': 'secret',
        'sni': 'example.com',
      });
      expect(link, isNotNull);
      expect(link, startsWith('trojan://secret@example.com:443'));
    });

    test('serializes a hysteria2 proxy', () {
      final link = proxyToShareLink({
        'type': 'hysteria2',
        'name': 'hy2',
        'server': 'example.com',
        'port': 443,
        'password': 'secret',
      });
      expect(link, isNotNull);
      expect(link, startsWith('hysteria2://secret@example.com:443'));
    });

    test('returns null for unknown types', () {
      expect(proxyToShareLink({'type': 'wireguard'}), isNull);
      expect(proxyToShareLink({}), isNull);
    });

    test('never throws on malformed input', () {
      expect(proxyToShareLink({'type': 'vless'}), isNull);
      expect(
        proxyToShareLink({'type': 'ss', 'server': 123, 'port': 'x'}),
        isNull,
      );
    });
  });
}
