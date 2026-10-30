import 'dart:io';

import 'package:fl_clash/common/shadowrocket_link.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeEffects implements ShadowrocketLinkEffects {
  final calls = <String>[];

  @override
  void startTunnel() => calls.add('start');

  @override
  void stopTunnel() => calls.add('stop');

  @override
  void toggleTunnel() => calls.add('toggle');

  @override
  void testConnectivity() => calls.add('test');

  @override
  void selectNode(String name) => calls.add('select:$name');

  @override
  void addProfile(String url) => calls.add('profile:$url');

  @override
  void updateSubscriptions() => calls.add('updateSubs');

  @override
  void addModule(String url) => calls.add('module:$url');

  @override
  void setRoute(ShadowrocketRoute route) => calls.add('route:$route');

  @override
  void unsupportedColor() => calls.add('color');
}

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

  group('dispatchShadowrocketLink', () {
    test('routes every action kind to its effect', () {
      final effects = _FakeEffects();
      const cases = [
        (ShadowrocketLinkAction(kind: ShadowrocketLinkKind.connect), 'start'),
        (ShadowrocketLinkAction(kind: ShadowrocketLinkKind.disconnect), 'stop'),
        (ShadowrocketLinkAction(kind: ShadowrocketLinkKind.toggle), 'toggle'),
        (
          ShadowrocketLinkAction(kind: ShadowrocketLinkKind.connectivityTest),
          'test',
        ),
        (
          ShadowrocketLinkAction(
            kind: ShadowrocketLinkKind.select,
            nodeName: 'NodeA',
          ),
          'select:NodeA',
        ),
        (
          ShadowrocketLinkAction(
            kind: ShadowrocketLinkKind.add,
            url: 'https://example.com/sub',
          ),
          'profile:https://example.com/sub',
        ),
        (
          ShadowrocketLinkAction(
            kind: ShadowrocketLinkKind.configAdd,
            url: 'https://example.com/x.conf',
          ),
          'profile:https://example.com/x.conf',
        ),
        (
          ShadowrocketLinkAction(kind: ShadowrocketLinkKind.updateSubs),
          'updateSubs',
        ),
        (
          ShadowrocketLinkAction(
            kind: ShadowrocketLinkKind.installModule,
            url: 'https://example.com/m.sgmodule',
          ),
          'module:https://example.com/m.sgmodule',
        ),
        (
          ShadowrocketLinkAction(
            kind: ShadowrocketLinkKind.route,
            route: ShadowrocketRoute.scene,
          ),
          'route:ShadowrocketRoute.scene',
        ),
        (ShadowrocketLinkAction(kind: ShadowrocketLinkKind.color), 'color'),
      ];
      for (final (action, expected) in cases) {
        dispatchShadowrocketLink(action, effects);
        expect(effects.calls.last, expected);
      }
    });
  });

  group('findSelectorGroupForNode', () {
    const groups = [
      Group(
        name: 'auto',
        type: GroupType.URLTest,
        all: [Proxy(name: 'NodeA', type: 'ss')],
      ),
      Group(
        name: 'manual',
        type: GroupType.Selector,
        all: [Proxy(name: 'NodeA', type: 'ss')],
      ),
    ];

    test('skips non-selector groups and returns the selector group', () {
      expect(findSelectorGroupForNode(groups, 'NodeA'), 'manual');
    });

    test('returns null when no selector group holds the node', () {
      expect(findSelectorGroupForNode(groups, 'NodeZ'), isNull);
    });
  });

  group('dedupeGroupProxies', () {
    test('keeps the first occurrence of each proxy name', () {
      const groups = [
        Group(
          name: 'g1',
          type: GroupType.Selector,
          all: [
            Proxy(name: 'NodeA', type: 'ss'),
            Proxy(name: 'NodeB', type: 'ss'),
          ],
        ),
        Group(
          name: 'g2',
          type: GroupType.Selector,
          all: [
            Proxy(name: 'NodeA', type: 'ss'),
            Proxy(name: 'NodeC', type: 'ss'),
          ],
        ),
      ];
      expect(dedupeGroupProxies(groups).map((proxy) => proxy.name), [
        'NodeA',
        'NodeB',
        'NodeC',
      ]);
    });
  });

  group('modeForShadowrocketRoute', () {
    test('maps proxy, config and direct; scene has no fixed mode', () {
      expect(modeForShadowrocketRoute(ShadowrocketRoute.proxy), Mode.global);
      expect(modeForShadowrocketRoute(ShadowrocketRoute.config), Mode.rule);
      expect(modeForShadowrocketRoute(ShadowrocketRoute.direct), Mode.direct);
      expect(modeForShadowrocketRoute(ShadowrocketRoute.scene), isNull);
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
