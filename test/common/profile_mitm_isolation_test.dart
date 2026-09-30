import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

MakeRealProfileState _state({
  required List<String> mitmHostnames,
  List<String> urlRewrites = const [],
}) => MakeRealProfileState(
  profilesPath: '/profiles',
  profileId: 7,
  rawConfig: {
    'proxies': [],
    'rules': ['MATCH,PROXY'],
  },
  realPatchConfig: const PatchClashConfig(),
  overrideDns: false,
  appendSystemDns: false,
  proxyGroups: const [],
  rules: const [],
  addedRules: const [],
  defaultUA: 'FlClash-Test',
  mitmHostnames: mitmHostnames,
  urlRewrites: urlRewrites,
);

List<String> _rulesOf(String yaml) =>
    List<String>.from((loadYaml(yaml) as YamlMap)['rules'] as YamlList);

void main() {
  group('makeRealProfileTask MITM isolation', () {
    test('profile MITM hostnames become PigCat-MITM rules', () async {
      final result = await makeRealProfileTask(
        _state(mitmHostnames: ['a.example.com']),
      );
      final rules = _rulesOf(result.yaml);
      expect(rules.first, 'DOMAIN,a.example.com,PigCat-MITM');
      final proxies = (loadYaml(result.yaml) as YamlMap)['proxies'] as YamlList;
      expect(
        proxies.any((p) => (p as YamlMap)['name'] == 'PigCat-MITM'),
        isTrue,
      );
    });

    test('switching profiles does not leak old MITM rules', () async {
      final first = await makeRealProfileTask(
        _state(mitmHostnames: ['a.example.com']),
      );
      expect(_rulesOf(first.yaml).first, 'DOMAIN,a.example.com,PigCat-MITM');

      final second = await makeRealProfileTask(
        _state(mitmHostnames: ['b.example.com']),
      );
      final rules = _rulesOf(second.yaml);
      expect(rules.first, 'DOMAIN,b.example.com,PigCat-MITM');
      expect(rules.any((r) => r.contains('a.example.com')), isFalse);
    });

    test('empty MITM hostnames add no proxy or rules', () async {
      final result = await makeRealProfileTask(_state(mitmHostnames: []));
      final rules = _rulesOf(result.yaml);
      expect(rules.any((r) => r.contains('PigCat-MITM')), isFalse);
      expect(rules, ['MATCH,PROXY']);
    });

    test('profile URL rewrites derive MITM hosts', () async {
      final result = await makeRealProfileTask(
        _state(
          mitmHostnames: [],
          urlRewrites: [r'^https?://rewrite.example.com/path 302'],
        ),
      );
      expect(
        _rulesOf(result.yaml).first,
        'DOMAIN,rewrite.example.com,PigCat-MITM',
      );
    });
  });
}
