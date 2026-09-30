import 'package:fl_clash/common/mitm_manager.dart';
import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseMapLocalLine', () {
    test('parses text type with defaults', () {
      final parsed = parseMapLocalLine(
        r'^https://track\.example\.com data-type=text data=""',
      );
      expect(parsed, isNotNull);
      expect(parsed!.pattern, r'^https://track\.example\.com');
      expect(parsed.dataType, 'text');
      expect(parsed.data, '');
      expect(parsed.statusCode, 200);
      expect(parsed.headers, isEmpty);
    });

    test('parses status code and extra headers', () {
      final parsed = parseMapLocalLine(
        r'^https://ads\.example\.com/pixel data-type=tiny-gif status-code=200 X-Cache=HIT',
      );
      expect(parsed, isNotNull);
      expect(parsed!.dataType, 'tiny-gif');
      expect(parsed.statusCode, 200);
      expect(parsed.headers, {'X-Cache': 'HIT'});
    });

    test('keeps quoted data with spaces and equals signs', () {
      final parsed = parseMapLocalLine(
        r'^https://api\.example\.com/mock data-type=text data="{"a": 1, "b": "x=y"}" status-code=201',
      );
      expect(parsed, isNotNull);
      expect(parsed!.data, '{"a": 1, "b": "x=y"}');
      expect(parsed.statusCode, 201);
    });

    test('parses base64 and file types', () {
      final b64 = parseMapLocalLine(
        r'^https://b\.example\.com data-type=base64 data="aGVsbG8="',
      );
      expect(b64, isNotNull);
      expect(b64!.dataType, 'base64');
      expect(b64.data, 'aGVsbG8=');

      final file = parseMapLocalLine(
        r'^https://f\.example\.com data-type=file data=/sdcard/mock.json',
      );
      expect(file, isNotNull);
      expect(file!.dataType, 'file');
    });

    test('rejects unknown data types and empty patterns', () {
      expect(
        parseMapLocalLine(r'^https://a.example.com data-type=yaml data=x'),
        isNull,
      );
      expect(parseMapLocalLine(''), isNull);
      expect(parseMapLocalLine('   '), isNull);
    });
  });

  group('parseMapLocalRules', () {
    test('converts lines to config maps and skips invalid ones', () {
      final rules = parseMapLocalRules([
        r'^https://a\.example\.com data-type=text data=hi status-code=204',
        // No data-type: rejected so a stray line can't become a live rule.
        'not a map local line without kv',
        r'^https://b\.example\.com data-type=bogus data=x',
      ]);
      expect(rules, hasLength(1));
      expect(rules[0]['pattern'], r'^https://a\.example\.com');
      expect(rules[0]['dataType'], 'text');
      expect(rules[0]['data'], 'hi');
      expect(rules[0]['statusCode'], 204);
    });
  });

  group('section parsing', () {
    test('parseSgmodule reads [Map Local]', () {
      final sg = parseSgmodule(
        '#!name=Ads\n[Map Local]\n'
        r'^https://ads\.example\.com data-type=text data="" status-code=204'
        '\n',
      );
      expect(sg.mapLocal, hasLength(1));
      expect(sg.needsMitm, isTrue);
      expect(sg.isEmpty, isFalse);
    });

    test('parseConf reads [Map Local]', () {
      final conf = parseConf(
        '[Map Local]\n'
        r'^https://ads\.example\.com data-type=tiny-gif'
        '\n',
      );
      expect(conf.mapLocal, hasLength(1));
      expect(conf.isEmpty, isFalse);
    });

    test('module arguments substitute inside [Map Local]', () {
      final sg = parseSgmoduleWithArguments(
        '#!name=Ads\n#!arguments=host:example.com\n[Map Local]\n'
        r'^https://{{{host}}}/ads data-type=text data=""'
        '\n',
        const {},
      );
      expect(sg.mapLocal.single, contains('example.com'));
      expect(sg.mapLocal.single, isNot(contains('{{{host}}}')));
    });
  });
}
