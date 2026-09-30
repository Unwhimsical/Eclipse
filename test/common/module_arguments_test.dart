import 'package:fl_clash/common/shadowrocket.dart';
import 'package:fl_clash/models/module.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSgmodule #!arguments', () {
    test('parses comma-separated key:default pairs', () {
      const raw =
          '#!name=Cert\n'
          '#!arguments=证书模块:false, 证书内容:此处粘贴有效的证书内容, 证书密码:Shadowrocket\n'
          '[MITM]\n'
          'enable={{{证书模块}}}\n';
      final sg = parseSgmodule(raw);
      expect(sg.arguments, hasLength(3));
      expect(sg.arguments[0].key, '证书模块');
      expect(sg.arguments[0].defaultValue, 'false');
      expect(sg.arguments[1].key, '证书内容');
      expect(sg.arguments[1].defaultValue, '此处粘贴有效的证书内容');
      expect(sg.arguments[2].key, '证书密码');
      expect(sg.arguments[2].defaultValue, 'Shadowrocket');
    });

    test('splits value on first colon only', () {
      final sg = parseSgmodule(
        '#!arguments=url:https://example.com:8080/x\n[Rule]\n',
      );
      expect(sg.arguments, hasLength(1));
      expect(sg.arguments[0].key, 'url');
      expect(sg.arguments[0].defaultValue, 'https://example.com:8080/x');
    });

    test('key without colon gets empty default', () {
      final sg = parseSgmodule('#!arguments=token\n[Rule]\n');
      expect(sg.arguments.single.key, 'token');
      expect(sg.arguments.single.defaultValue, '');
    });

    test('skips empty entries', () {
      final sg = parseSgmodule('#!arguments=, ,a:1,,\n[Rule]\n');
      expect(sg.arguments, hasLength(1));
      expect(sg.arguments.single.key, 'a');
    });

    test('module without arguments has empty list', () {
      final sg = parseSgmodule('#!name=X\n[Rule]\n');
      expect(sg.arguments, isEmpty);
    });

    test('parses arguments-desc with newline escapes', () {
      const raw =
          '#!arguments=a:1, b:2\n'
          '#!arguments-desc=a：first param\\n\\nb：second param\n'
          '[Rule]\n';
      final sg = parseSgmodule(raw);
      expect(sg.argumentDescriptions['a'], 'first param');
      expect(sg.argumentDescriptions['b'], 'second param');
    });
  });

  group('substituteModuleArguments', () {
    test('replaces triple-brace placeholders', () {
      expect(
        substituteModuleArguments('enable={{{证书模块}}}', {'证书模块': 'true'}),
        'enable=true',
      );
    });

    test('tolerates whitespace inside braces', () {
      expect(substituteModuleArguments('x={{{ key }}}', {'key': 'v'}), 'x=v');
    });

    test('leaves unknown keys intact', () {
      expect(
        substituteModuleArguments('x={{{nope}}}', {'key': 'v'}),
        'x={{{nope}}}',
      );
    });

    test('empty user value replaces with empty string', () {
      expect(substituteModuleArguments('x={{{key}}}', {'key': ''}), 'x=');
    });

    test('replaces multiple occurrences', () {
      expect(substituteModuleArguments('{{{a}}}-{{{a}}}', {'a': '1'}), '1-1');
    });
  });

  group('effectiveModuleArguments', () {
    test('user values win, defaults fill the rest', () {
      final sg = parseSgmodule('#!arguments=a:1, b:2, c:3\n[Rule]\n');
      expect(effectiveModuleArguments(sg, {'b': '20'}), {
        'a': '1',
        'b': '20',
        'c': '3',
      });
    });

    test('drops user values for undeclared keys', () {
      final sg = parseSgmodule('#!arguments=a:1\n[Rule]\n');
      expect(effectiveModuleArguments(sg, {'zzz': '9'}), {'a': '1'});
    });
  });

  group('parseSgmoduleWithArguments', () {
    test('substitutes placeholders with defaults', () {
      const raw =
          '#!name=M\n'
          '#!arguments=host:example.com\n'
          '[Rule]\n'
          'DOMAIN-SUFFIX,{{{host}}},REJECT\n'
          '[MITM]\n'
          'hostname = {{{host}}}\n';
      final sg = parseSgmoduleWithArguments(raw, const {});
      expect(sg.rules, ['DOMAIN-SUFFIX,example.com,REJECT']);
      expect(sg.mitmHostnames, ['example.com']);
      expect(sg.arguments, hasLength(1));
    });

    test('user values override defaults', () {
      const raw =
          '#!name=M\n'
          '#!arguments=host:example.com\n'
          '[Rule]\n'
          'DOMAIN-SUFFIX,{{{host}}},REJECT\n';
      final sg = parseSgmoduleWithArguments(raw, {'host': 'other.com'});
      expect(sg.rules, ['DOMAIN-SUFFIX,other.com,REJECT']);
    });

    test('no arguments behaves like parseSgmodule', () {
      const raw = '#!name=M\n[Rule]\nDOMAIN-SUFFIX,a.com,REJECT\n';
      final sg = parseSgmoduleWithArguments(raw, const {});
      expect(sg.rules, ['DOMAIN-SUFFIX,a.com,REJECT']);
    });

    test('substitutes script argument lines', () {
      const raw =
          '#!name=M\n'
          '#!arguments=lat:39.9\n'
          '[Script]\n'
          'loc = type=http-request,pattern=.*,argument=lat={{{lat}}},script-path=https://example.com/a.js\n';
      final sg = parseSgmoduleWithArguments(raw, {'lat': '31.2'});
      expect(sg.scripts.single, contains('argument=lat=31.2'));
    });
  });

  group('ModuleInfo.argumentValues', () {
    test('toJson/fromJson roundtrip', () {
      final info = ModuleInfo(
        id: '1',
        name: 'M',
        importDate: DateTime.utc(2026, 1, 1),
        argumentValues: {'a': '1', 'b': 'x'},
      );
      expect(ModuleInfo.fromJson(info.toJson()).argumentValues, {
        'a': '1',
        'b': 'x',
      });
    });

    test('defaults to empty map for old records', () {
      final info = ModuleInfo.fromJson({
        'id': '1',
        'name': 'M',
        'importDate': DateTime.utc(2026, 1, 1).toIso8601String(),
      });
      expect(info.argumentValues, isEmpty);
    });

    test('copyWith updates argumentValues', () {
      final info = ModuleInfo(
        id: '1',
        name: 'M',
        importDate: DateTime.now(),
      ).copyWith(argumentValues: {'k': 'v'});
      expect(info.argumentValues, {'k': 'v'});
    });
  });
}
