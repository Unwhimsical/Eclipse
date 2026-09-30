import 'package:fl_clash/common/shadowrocket.dart';
import 'package:fl_clash/models/module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSgmodule %APPEND%', () {
    test('sets rulesAppend and keeps %APPEND% out of rules', () {
      const content = '''
[Rule]
%APPEND%
DOMAIN-SUFFIX,example.com,PROXY
''';
      final sg = parseSgmodule(content);
      expect(sg.rulesAppend, isTrue);
      expect(sg.rules, ['DOMAIN-SUFFIX,example.com,PROXY']);
      expect(sg.rules.any((r) => r.contains('%APPEND%')), isFalse);
    });

    test('matches %APPEND% case-insensitively', () {
      const content = '''
[Rule]
%append%
DOMAIN,example.com,PROXY
''';
      final sg = parseSgmodule(content);
      expect(sg.rulesAppend, isTrue);
      expect(sg.rules, hasLength(1));
    });

    test('defaults rulesAppend to false without the directive', () {
      const content = '''
[Rule]
DOMAIN,example.com,PROXY
''';
      final sg = parseSgmodule(content);
      expect(sg.rulesAppend, isFalse);
      expect(sg.rules, ['DOMAIN,example.com,PROXY']);
    });

    test('ignores other % directives without setting rulesAppend', () {
      const content = '''
[Rule]
%SOME-OTHER%
DOMAIN,example.com,PROXY
''';
      final sg = parseSgmodule(content);
      expect(sg.rulesAppend, isFalse);
      expect(sg.rules, ['DOMAIN,example.com,PROXY']);
    });
  });

  group('ModuleInfo rulesAppend', () {
    ModuleInfo info() => ModuleInfo(
      id: 'm1',
      name: 'm1',
      rulesAppend: false,
      importDate: DateTime.utc(2026, 1, 1),
    );

    test('round-trips through json', () {
      final restored = ModuleInfo.fromJson(info().toJson());
      expect(restored.rulesAppend, isFalse);
    });

    test('old json without the flag defaults to append', () {
      final json = info().toJson()..remove('rulesAppend');
      expect(ModuleInfo.fromJson(json).rulesAppend, isTrue);
    });

    test('copyWith preserves the flag by default', () {
      expect(info().copyWith().rulesAppend, isFalse);
      expect(info().copyWith(rulesAppend: true).rulesAppend, isTrue);
    });
  });
}
