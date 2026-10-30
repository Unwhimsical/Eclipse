import 'dart:io';

import 'package:fl_clash/common/shadowrocket_link.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseShadowrocketLink', () {
    test('maps connect and open to connect', () {
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://connect'))?.kind,
        ShadowrocketLinkKind.connect,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://open'))?.kind,
        ShadowrocketLinkKind.connect,
      );
    });

    test('maps disconnect and close to disconnect', () {
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://disconnect'))?.kind,
        ShadowrocketLinkKind.disconnect,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://close'))?.kind,
        ShadowrocketLinkKind.disconnect,
      );
    });

    test('maps toggle, connectivity-test and update-subs', () {
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://toggle'))?.kind,
        ShadowrocketLinkKind.toggle,
      );
      expect(
        parseShadowrocketLink(
          Uri.parse('shadowrocket://connectivity-test'),
        )?.kind,
        ShadowrocketLinkKind.connectivityTest,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://update-subs'))?.kind,
        ShadowrocketLinkKind.updateSubs,
      );
    });

    test('parses select with a node name and autoclose', () {
      final action = parseShadowrocketLink(
        Uri.parse('shadowrocket://select?s=NodeA&autoclose=true'),
      );
      expect(action?.kind, ShadowrocketLinkKind.select);
      expect(action?.nodeName, 'NodeA');
      expect(action?.autoClose, isTrue);
    });

    test('parses add with an embedded subscription url', () {
      final action = parseShadowrocketLink(
        Uri.parse('shadowrocket://add/https://example.com/sub?token=1'),
      );
      expect(action?.kind, ShadowrocketLinkKind.add);
      expect(action?.url, 'https://example.com/sub?token=1');
    });

    test('decodes a percent-encoded add url', () {
      final action = parseShadowrocketLink(
        Uri.parse('shadowrocket://add/https%3A%2F%2Fexample.com%2Fsub'),
      );
      expect(action?.kind, ShadowrocketLinkKind.add);
      expect(action?.url, 'https://example.com/sub');
    });

    test('parses config add and module install', () {
      final config = parseShadowrocketLink(
        Uri.parse('shadowrocket://config/add/https://example.com/x.conf'),
      );
      expect(config?.kind, ShadowrocketLinkKind.configAdd);
      expect(config?.url, 'https://example.com/x.conf');
      final module = parseShadowrocketLink(
        Uri.parse(
          'shadowrocket://install?module=https://example.com/m.sgmodule',
        ),
      );
      expect(module?.kind, ShadowrocketLinkKind.installModule);
      expect(module?.url, 'https://example.com/m.sgmodule');
    });

    test('maps every route target', () {
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://route/proxy'))?.route,
        ShadowrocketRoute.proxy,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://route/config'))?.route,
        ShadowrocketRoute.config,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://route/direct'))?.route,
        ShadowrocketRoute.direct,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://route/scene'))?.route,
        ShadowrocketRoute.scene,
      );
    });

    test('parses a color payload', () {
      expect(
        parseShadowrocketLink(
          Uri.parse('shadowrocket://color?background=000000'),
        )?.kind,
        ShadowrocketLinkKind.color,
      );
    });

    test('rejects other schemes', () {
      expect(parseShadowrocketLink(Uri.parse('clash://connect')), isNull);
      expect(parseShadowrocketLink(Uri.parse('https://example.com')), isNull);
    });

    test('rejects unknown hosts and routes', () {
      expect(parseShadowrocketLink(Uri.parse('shadowrocket://fly')), isNull);
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://route/nowhere')),
        isNull,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://install-config')),
        isNull,
      );
    });

    test('rejects select without a node name', () {
      expect(parseShadowrocketLink(Uri.parse('shadowrocket://select')), isNull);
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://select?s=')),
        isNull,
      );
    });

    test('rejects install without an http module url', () {
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://install')),
        isNull,
      );
      expect(
        parseShadowrocketLink(
          Uri.parse('shadowrocket://install?module=ftp://example.com/m'),
        ),
        isNull,
      );
    });

    test('rejects add without an http url', () {
      expect(parseShadowrocketLink(Uri.parse('shadowrocket://add/')), isNull);
      expect(
        parseShadowrocketLink(
          Uri.parse('shadowrocket://add/ftp://example.com'),
        ),
        isNull,
      );
    });

    test('rejects undefined query parameters and bad autoclose', () {
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://connect?foo=1')),
        isNull,
      );
      expect(
        parseShadowrocketLink(Uri.parse('shadowrocket://connect?autoclose=1')),
        isNull,
      );
      expect(parseShadowrocketLink(Uri.parse('shadowrocket://color')), isNull);
    });
  });

  group('scheme registration files', () {
    test('Windows installer cleanup covers shadowrocket', () {
      final iss = File(
        'windows/packaging/exe/inno_setup.iss',
      ).readAsStringSync();
      expect(iss, contains("'shadowrocket'"));
    });

    test('iOS Info.plist registers shadowrocket', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      expect(plist, contains('<string>shadowrocket</string>'));
      expect(plist, contains('<string>clash</string>'));
      expect(plist, contains('<string>clashmeta</string>'));
    });
  });
}
