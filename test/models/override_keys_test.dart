import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

/// Helper to round-trip a model through JSON encode/decode.
T roundTrip<T>(
  Object? Function() toJson,
  T Function(Map<String, Object?> json) fromJson,
) {
  final encoded = jsonEncode(toJson());
  final decoded = jsonDecode(encoded) as Map<String, Object?>;
  return fromJson(decoded);
}

void main() {
  group('OverrideKey', () {
    test('parses parent and field from dotted paths', () {
      expect(DnsOverrideKey.enable.parent, isNull);
      expect(DnsOverrideKey.enable.field, 'enable');
      expect(
        DnsOverrideKey.fallbackFilterGeoip.parent,
        DnsOverrideKey.fallbackFilterSection,
      );
      expect(DnsOverrideKey.fallbackFilterGeoip.field, 'geoip');
      expect(TunOverrideKey.dnsHijack.parent, isNull);
      expect(TunOverrideKey.dnsHijack.field, 'dns-hijack');
    });

    test('paths are unique within each enum', () {
      for (final List<OverrideKey> values in [
        DnsOverrideKey.values,
        TunOverrideKey.values,
      ]) {
        final paths = values.map((key) => key.path).toList();
        expect(paths.toSet(), hasLength(paths.length));
      }
    });
  });

  group('Dns overrideJson', () {
    test('picks only the selected keys', () {
      const dns = Dns(
        enable: true,
        enhancedMode: DnsMode.fakeIp,
        nameserver: ['https://doh.pub/dns-query'],
        listen: '127.0.0.1:1053',
      );
      final json = dns.overrideJson({
        DnsOverrideKey.enhancedMode,
        DnsOverrideKey.nameserver,
      });

      expect(json['enhanced-mode'], 'fake-ip');
      expect(json['nameserver'], ['https://doh.pub/dns-query']);
      expect(json.containsKey('enable'), isFalse);
      expect(json.containsKey('listen'), isFalse);
    });

    test('skips unset values', () {
      const dns = Dns(nameserver: []);
      final json = dns.overrideJson({DnsOverrideKey.nameserver});
      expect(json.containsKey('nameserver'), isFalse);
    });

    test('nests fallback-filter keys under their section', () {
      const dns = Dns(
        fallbackFilter: FallbackFilter(geoip: false, geosite: ['gfw']),
      );
      final json = dns.overrideJson({
        DnsOverrideKey.fallbackFilterGeoip,
        DnsOverrideKey.fallbackFilterGeosite,
      });

      expect(json['fallback-filter'], {
        'geoip': false,
        'geosite': ['gfw'],
      });
    });

    test('splits nameserver-policy servers', () {
      const dns = Dns(nameserverPolicy: {'example.com': '1.1.1.1, 8.8.8.8'});
      final json = dns.overrideJson({DnsOverrideKey.nameserverPolicy});

      expect(json['nameserver-policy'], {
        'example.com': ['1.1.1.1', '8.8.8.8'],
      });
    });
  });

  group('Tun overrideJson', () {
    test('picks only the selected keys and never enable', () {
      const tun = Tun(stack: TunStack.gvisor, udp: false);
      final json = tun.overrideJson({TunOverrideKey.stack, TunOverrideKey.udp});

      expect(json['stack'], 'gvisor');
      expect(json['udp'], false);
      expect(json.containsKey('enable'), isFalse);
      expect(json.containsKey('device'), isFalse);
    });
  });

  group('mergeDnsOverride', () {
    test('merges the fallback-filter section key by key', () {
      final merged = mergeDnsOverride(
        {
          'enable': true,
          'fallback-filter': {
            'geoip': true,
            'domain': ['+.example.com'],
          },
        },
        {
          'fallback-filter': {'geoip': false},
          'nameserver': ['1.1.1.1'],
        },
      );

      expect(merged['enable'], true);
      expect(merged['nameserver'], ['1.1.1.1']);
      expect(merged['fallback-filter'], {
        'geoip': false,
        'domain': ['+.example.com'],
      });
    });
  });

  group('override key sets JSON', () {
    test('PatchClashConfig round-trips picked keys', () {
      const config = PatchClashConfig(
        dnsOverrideKeys: {
          DnsOverrideKey.nameserver,
          DnsOverrideKey.fallbackFilterGeoip,
        },
        tunOverrideKeys: {TunOverrideKey.stack},
      );
      final restored = roundTrip(
        () => config.toJson(),
        PatchClashConfig.fromJson,
      );

      expect(restored.dnsOverrideKeys, {
        DnsOverrideKey.nameserver,
        DnsOverrideKey.fallbackFilterGeoip,
      });
      expect(restored.tunOverrideKeys, {TunOverrideKey.stack});
    });

    test('unknown key paths are ignored', () {
      final config = PatchClashConfig.fromJson({
        'dns-override-keys': ['nameserver', 'no-such-key'],
        'tun-override-keys': ['stack'],
      });

      expect(config.dnsOverrideKeys, {DnsOverrideKey.nameserver});
      expect(config.tunOverrideKeys, {TunOverrideKey.stack});
    });

    test('defaults keep legacy behavior', () {
      const config = PatchClashConfig();
      expect(config.dnsOverrideKeys, isEmpty);
      expect(config.tunOverrideKeys, TunOverrideKey.values.toSet());
    });
  });
}
