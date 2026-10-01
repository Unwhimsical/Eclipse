import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';

const _moduleWithArgs = '''
#!name=Arg Module
#!arguments=host:example.com,port:8080
#!arguments-desc=host: target host

[Rule]
DOMAIN-SUFFIX,{{{host}}},PROXY
DOMAIN,static.example.com,DIRECT

[Host]
{{{host}}} = 127.0.0.1:{{{port}}}

[URL Rewrite]
^https://{{{host}}}/ad http://127.0.0.1/empty 302
''';

const _moduleNoArgs = '''
#!name=Plain Module

[Rule]
DOMAIN-SUFFIX,example.org,REJECT
''';

bool _sameModule(Sgmodule a, Sgmodule b) {
  return a.name == b.name &&
      a.desc == b.desc &&
      a.author == b.author &&
      a.rules.join('\n') == b.rules.join('\n') &&
      a.hosts.toString() == b.hosts.toString() &&
      a.urlRewrites.join('\n') == b.urlRewrites.join('\n') &&
      a.rulesAppend == b.rulesAppend &&
      a.arguments.map((e) => '${e.key}=${e.defaultValue}').join(',') ==
          b.arguments.map((e) => '${e.key}=${e.defaultValue}').join(',') &&
      a.granularRejects.map((e) => e.toJson().toString()).join(',') ==
          b.granularRejects.map((e) => e.toJson().toString()).join(',');
}

void main() {
  group('parseSgmoduleWithArguments single-pass', () {
    test('no arguments: identical to parseSgmodule', () {
      final direct = parseSgmodule(_moduleNoArgs);
      final via = parseSgmoduleWithArguments(_moduleNoArgs, const {});
      expect(_sameModule(direct, via), isTrue);
    });

    test('defaults are substituted', () {
      final sg = parseSgmoduleWithArguments(_moduleWithArgs, const {});
      expect(sg.rules, contains('DOMAIN-SUFFIX,example.com,PROXY'));
      expect(sg.hosts['example.com'], '127.0.0.1:8080');
      expect(
        sg.urlRewrites.single,
        '^https://example.com/ad http://127.0.0.1/empty 302',
      );
    });

    test('user values override defaults', () {
      final sg = parseSgmoduleWithArguments(_moduleWithArgs, {
        'host': 'other.com',
        'port': '9090',
      });
      expect(sg.rules, contains('DOMAIN-SUFFIX,other.com,PROXY'));
      expect(sg.hosts['other.com'], '127.0.0.1:9090');
    });

    test('unknown placeholders are left intact', () {
      const raw = '[Rule]\nDOMAIN,{{{nope}}}.example.com,PROXY\n';
      final sg = parseSgmoduleWithArguments(raw, const {});
      expect(sg.rules.single, 'DOMAIN,{{{nope}}}.example.com,PROXY');
    });

    test('scanModuleArguments matches the full parse declarations', () {
      final scanned = scanModuleArguments(_moduleWithArgs);
      final parsed = parseSgmodule(_moduleWithArgs).arguments;
      expect(
        scanned.map((e) => '${e.key}=${e.defaultValue}'),
        parsed.map((e) => '${e.key}=${e.defaultValue}'),
      );
    });

    test('scanModuleArguments is empty when undeclared', () {
      expect(scanModuleArguments(_moduleNoArgs), isEmpty);
    });

    test('last #!arguments declaration wins, like the full parse', () {
      const raw = '#!arguments=a:1\n#!arguments=b:2\n[Rule]\n';
      final scanned = scanModuleArguments(raw).map((e) => e.key);
      final parsed = parseSgmodule(raw).arguments.map((e) => e.key);
      expect(scanned, ['b']);
      expect(scanned, parsed);
    });
  });

  group('parseSgmoduleWithArgumentsBackground', () {
    test('returns the same module as the sync parse', () async {
      final expected = parseSgmoduleWithArguments(_moduleWithArgs, {
        'host': 'bg.example.com',
      });
      final actual = await parseSgmoduleWithArgumentsBackground(
        _moduleWithArgs,
        {'host': 'bg.example.com'},
      );
      expect(_sameModule(expected, actual), isTrue);
      expect(actual.rules, contains('DOMAIN-SUFFIX,bg.example.com,PROXY'));
    });

    test('handles a large module off the main isolate', () async {
      final buf = StringBuffer('[Rule]\n');
      for (var i = 0; i < 20000; i++) {
        buf.writeln('DOMAIN-SUFFIX,host$i.example.com,REJECT');
      }
      final raw = buf.toString();
      final sg = await parseSgmoduleWithArgumentsBackground(raw, const {});
      expect(sg.rules.length, 20000);
      expect(sg.rules.first, 'DOMAIN-SUFFIX,host0.example.com,REJECT');
    });
  });
}
