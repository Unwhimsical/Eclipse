import 'dart:convert';

import 'package:fl_clash/common/shadowrocket.dart';
import 'package:fl_clash/common/sr_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShadowrocketImport.parseLinkList', () {
    test('parses multiple links', () {
      final proxies = ShadowrocketImport.parseLinkList(
        'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388#one\n'
        'trojan://password@example.org:443#two\n',
      );
      expect(proxies, hasLength(2));
      expect(proxies[0]['name'], 'one');
      expect(proxies[1]['name'], 'two');
    });

    test('skips invalid lines', () {
      final proxies = ShadowrocketImport.parseLinkList(
        'not a link\n'
        'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388#one\n',
      );
      expect(proxies, hasLength(1));
    });

    test('decodes base64 subscription body', () {
      final body = base64Encode(
        utf8.encode(
          'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388#one\n'
          'trojan://password@example.org:443#two\n',
        ),
      );
      final proxies = ShadowrocketImport.parseLinkList(body);
      expect(proxies, hasLength(2));
    });

    test('returns empty for garbage', () {
      expect(ShadowrocketImport.parseLinkList(''), isEmpty);
      expect(ShadowrocketImport.parseLinkList('!!!not-base64!!!'), isEmpty);
    });
  });

  group('ShadowrocketImport.fileNameFromUrl', () {
    test('extracts file name', () {
      expect(
        ShadowrocketImport.fileNameFromUrl(
          'https://example.com/modules/test.sgmodule',
        ),
        'test.sgmodule',
      );
    });

    test('strips query params', () {
      expect(
        ShadowrocketImport.fileNameFromUrl(
          'https://example.com/a.conf?token=123',
        ),
        'a.conf',
      );
    });

    test('falls back to url when empty', () {
      expect(ShadowrocketImport.fileNameFromUrl(''), '');
    });
  });

  group('ShadowrocketImport MITM helpers', () {
    test('parseMitmEnabled reads the enable flag', () {
      expect(ShadowrocketImport.parseMitmEnabled({'enable': 'true'}), isTrue);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': 'TRUE'}), isTrue);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': ' true '}), isTrue);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': 'false'}), isFalse);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': '1'}), isFalse);
      expect(ShadowrocketImport.parseMitmEnabled({}), isFalse);
    });

    test('parseMitmHostnames splits and trims the hostname list', () {
      expect(
        ShadowrocketImport.parseMitmHostnames({
          'hostname': 'gs-loc.apple.com, gs-loc-cn.apple.com',
        }),
        ['gs-loc.apple.com', 'gs-loc-cn.apple.com'],
      );
      expect(
        ShadowrocketImport.parseMitmHostnames({'hostname': 'a.com,, ,b.com,'}),
        ['a.com', 'b.com'],
      );
      expect(ShadowrocketImport.parseMitmHostnames({}), isEmpty);
      expect(ShadowrocketImport.parseMitmHostnames({'hostname': ''}), isEmpty);
    });
  });

  group('ShadowrocketImport.generalSettingsFromConf', () {
    test('maps supported [General] keys and skips unsupported core keys', () {
      final settings = ShadowrocketImport.generalSettingsFromConf(
        parseConf(
          '[General]\n'
          'dns-server = 1.1.1.1, 8.8.8.8\n'
          'fallback-dns-server = 9.9.9.9\n'
          'direct-dns-server = 223.5.5.5\n'
          'skip-proxy = example.com\n'
          'tun-excluded-routes = 192.168.0.0/16\n'
          'tun-included-routes = 10.0.0.0/8\n'
          'ipv6 = true\n'
          'prefer-ipv6 = true\n'
          'private-ip-answer = false\n'
          'always-real-ip = yes\n',
        ),
      );
      expect(settings.dnsServers, ['1.1.1.1', '8.8.8.8']);
      expect(settings.fallbackDnsServers, ['9.9.9.9']);
      expect(settings.directDnsServers, ['223.5.5.5']);
      expect(settings.skipProxy, ['example.com']);
      expect(settings.tunExcludedRoutes, ['192.168.0.0/16']);
      expect(settings.tunIncludedRoutes, ['10.0.0.0/8']);
      expect(settings.ipv6, isTrue);
      expect(settings.preferIpv6, isTrue);
      expect(settings.privateIpAnswer, isFalse);
      expect(settings.alwaysRealIp, isTrue);
    });

    test('leaves ipv6 null when the key is absent', () {
      final settings = ShadowrocketImport.generalSettingsFromConf(
        parseConf('[General]\ndns-server = 1.1.1.1\n'),
      );
      expect(settings.ipv6, isNull);
      expect(settings.dnsServers, ['1.1.1.1']);
    });

    test('leaves unsupported tri-state params null when absent or garbage', () {
      final absent = ShadowrocketImport.generalSettingsFromConf(
        parseConf('[General]\ndns-server = 1.1.1.1\n'),
      );
      expect(absent.preferIpv6, isNull);
      expect(absent.privateIpAnswer, isNull);
      expect(absent.alwaysRealIp, isNull);

      final garbage = ShadowrocketImport.generalSettingsFromConf(
        parseConf(
          '[General]\n'
          'prefer-ipv6 = maybe\n'
          'private-ip-answer = 1.2.3.4\n'
          'always-real-ip = *.example.com\n',
        ),
      );
      expect(garbage.preferIpv6, isNull);
      expect(garbage.privateIpAnswer, isNull);
      expect(garbage.alwaysRealIp, isNull);
    });
  });
}
