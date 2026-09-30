import 'dart:io';

import 'package:fl_clash/common/mitm_manager.dart';
import 'package:fl_clash/common/module_store.dart';
import 'package:fl_clash/common/shadowrocket.dart';
import 'package:fl_clash/common/task.dart';
import 'package:fl_clash/core/core.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('parseGranularRejectLine', () {
    test('maps all six actions to Go rewrite kinds', () {
      final kinds = {
        'REJECT-DICT': ('reject-json', 200),
        'REJECT-ARRAY': ('reject-array', 200),
        'REJECT-200': ('reject', 200),
        'REJECT-IMG': ('reject-img', 200),
        'REJECT-TINYGIF': ('reject-img', 200),
        'REJECT-VIDEO': ('reject-video', 200),
      };
      for (final entry in kinds.entries) {
        final rule = parseGranularRejectLine(
          'DOMAIN-SUFFIX,ads.example.com,${entry.key}',
        );
        expect(rule, isNotNull);
        expect(rule!.kind, entry.value.$1);
        expect(rule.status, entry.value.$2);
      }
    });

    test('derives host patterns per rule type', () {
      expect(
        parseGranularRejectLine(
          'DOMAIN,ads.example.com,REJECT-DICT',
        )!.hostPattern,
        'ads.example.com',
      );
      expect(
        parseGranularRejectLine(
          'DOMAIN-SUFFIX,ads.example.com,REJECT-200',
        )!.hostPattern,
        '*.ads.example.com',
      );
      expect(
        parseGranularRejectLine('DOMAIN-KEYWORD,ads,REJECT-IMG')!.hostPattern,
        '*ads*',
      );
    });

    test('is case-insensitive', () {
      final rule = parseGranularRejectLine(
        'domain-suffix,Ads.Example.COM,reject-dict',
      );
      expect(rule, isNotNull);
      expect(rule!.hostPattern, '*.ads.example.com');
      expect(rule.kind, 'reject-json');
    });

    test('returns null for non-granular or unmappable lines', () {
      expect(parseGranularRejectLine('DOMAIN-SUFFIX,x.com,REJECT'), isNull);
      expect(
        parseGranularRejectLine('DOMAIN-SUFFIX,x.com,REJECT-DROP'),
        isNull,
      );
      expect(parseGranularRejectLine('DOMAIN-SUFFIX,x.com,PROXY'), isNull);
      expect(parseGranularRejectLine('IP-CIDR,1.2.3.0/24,REJECT-DICT'), isNull);
      expect(
        parseGranularRejectLine(r'URL-REGEX,^https?://x,REJECT-200'),
        isNull,
      );
      expect(parseGranularRejectLine('GEOIP,CN,REJECT-IMG'), isNull);
      expect(parseGranularRejectLine(''), isNull);
      expect(parseGranularRejectLine('# comment'), isNull);
      expect(parseGranularRejectLine('DOMAIN-SUFFIX,x.com'), isNull);
    });
  });

  group('parseSgmodule granular rejects', () {
    test('collects entries in file order and flattens rules', () {
      final sg = parseSgmodule(
        '[Rule]\n'
        'DOMAIN-SUFFIX,ads.example.com,REJECT-DICT\n'
        'DOMAIN,tracker.example.com,REJECT-200\n'
        'DOMAIN-SUFFIX,ok.example.com,PROXY\n',
      );
      expect(sg.granularRejects.length, 2);
      expect(sg.granularRejects[0].hostPattern, '*.ads.example.com');
      expect(sg.granularRejects[0].kind, 'reject-json');
      expect(sg.granularRejects[1].hostPattern, 'tracker.example.com');
      // The Mihomo-facing rules stay valid proxy names.
      expect(sg.rules, [
        'DOMAIN-SUFFIX,ads.example.com,REJECT',
        'DOMAIN,tracker.example.com,REJECT',
        'DOMAIN-SUFFIX,ok.example.com,PROXY',
      ]);
    });

    test('needsMitm is true with only granular rejects', () {
      final sg = parseSgmodule(
        '[Rule]\nDOMAIN-SUFFIX,ads.example.com,REJECT-DICT\n',
      );
      expect(sg.needsMitm, isTrue);
    });
  });

  group('mitmRulesForHosts', () {
    test('maps keyword patterns to DOMAIN-KEYWORD', () {
      expect(mitmRulesForHosts({'*ads*'}), ['DOMAIN-KEYWORD,ads,PigCat-MITM']);
    });

    test('keeps suffix and exact mappings', () {
      expect(
        mitmRulesForHosts({'*.example.com', 'exact.example.com'}),
        unorderedEquals([
          'DOMAIN-SUFFIX,example.com,PigCat-MITM',
          'DOMAIN,exact.example.com,PigCat-MITM',
        ]),
      );
    });
  });

  group('MitmManager granular rejects', () {
    late Directory root;

    setUpAll(() async {
      root = await Directory.systemTemp.createTemp('granular_reject_test');
      PathProviderPlatform.instance = _FakePathProvider(root.path);
      SharedPreferences.setMockInitialValues({});
      registerFallbackValue(<String, dynamic>{});
      final caDir = await Directory(p.join(root.path, 'ca')).create();
      await File(p.join(caDir.path, 'ca.crt')).writeAsString('cert');
      await File(p.join(caDir.path, 'ca.key')).writeAsString('key');
    });

    tearDownAll(() {
      if (root.existsSync()) {
        root.deleteSync(recursive: true);
      }
    });

    test('passes reject rules and host patterns to the Go proxy', () async {
      await ModuleStore().import(
        '[Rule]\n'
        'DOMAIN-SUFFIX,ads.example.com,REJECT-DICT\n'
        'DOMAIN,tracker.example.com,REJECT-IMG\n'
        'DOMAIN-KEYWORD,banner,REJECT-200\n',
      );
      final handler = _MockCoreHandlerInterface();
      when(
        () => handler.mitmUpdateConfig(any()),
      ).thenAnswer((_) async => {'running': false});
      Map<String, dynamic>? startedConfig;
      when(() => handler.mitmStart(any())).thenAnswer((invocation) async {
        startedConfig = Map<String, dynamic>.from(
          invocation.positionalArguments.first as Map,
        );
        return <String, dynamic>{};
      });
      final manager = MitmManager(CoreController.scoped(handler));

      final started = await manager.syncAndStart();

      expect(started, isTrue);
      expect(startedConfig, isNotNull);
      final hosts = (startedConfig!['hosts'] as List).toSet();
      expect(
        hosts,
        containsAll(['*.ads.example.com', 'tracker.example.com', '*banner*']),
      );
      final rejectRules = startedConfig!['rejectRules'] as List;
      expect(rejectRules.length, 3);
      expect(
        rejectRules.map((e) => (e as Map)['host']),
        containsAll(['*.ads.example.com', 'tracker.example.com', '*banner*']),
      );
      expect((rejectRules.first as Map)['kind'], 'reject-json');
    });
  });
}
