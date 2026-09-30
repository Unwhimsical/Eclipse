import 'package:fl_clash/common/mitm_manager.dart';
import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBodyRewriteLine', () {
    test('parses http-response regex rewrite', () {
      final parsed = parseBodyRewriteLine(
        r'http-response ^https://ad\.example\.com/ banner\d+ REPLACED',
      );
      expect(parsed, isNotNull);
      expect(parsed!.type, 'http-response');
      expect(parsed.pattern, r'^https://ad\.example\.com/');
      expect(parsed.regex, r'banner\d+');
      expect(parsed.replacement, 'REPLACED');
      expect(parsed.jq, isEmpty);
    });

    test('keeps spaces inside the replacement', () {
      final parsed = parseBodyRewriteLine(
        r'http-request ^https://api\.example\.com/ foo bar baz qux',
      );
      expect(parsed, isNotNull);
      expect(parsed!.regex, 'foo');
      expect(parsed.replacement, 'bar baz qux');
    });

    test('parses http-response-jq', () {
      final parsed = parseBodyRewriteLine(
        r'http-response-jq ^https://api\.example\.com/feed del(.ads) | .data',
      );
      expect(parsed, isNotNull);
      expect(parsed!.type, 'http-response-jq');
      expect(parsed.pattern, r'^https://api\.example\.com/feed');
      expect(parsed.jq, 'del(.ads) | .data');
      expect(parsed.regex, isEmpty);
    });

    test('parses http-request-jq', () {
      final parsed = parseBodyRewriteLine(
        r'http-request-jq ^https://api\.example\.com/login .password = "***"',
      );
      expect(parsed, isNotNull);
      expect(parsed!.type, 'http-request-jq');
      expect(parsed.jq, '.password = "***"');
    });

    test('rejects unknown types and short lines', () {
      expect(parseBodyRewriteLine('http-ftp ^https://a/ x y'), isNull);
      expect(parseBodyRewriteLine('http-response ^https://a/'), isNull);
      expect(parseBodyRewriteLine('http-response-jq ^https://a/'), isNull);
      expect(parseBodyRewriteLine('http-response'), isNull);
      expect(parseBodyRewriteLine(''), isNull);
    });

    test('type matching is case-insensitive', () {
      final parsed = parseBodyRewriteLine(
        r'HTTP-Response ^https://a\.example\.com/ x y',
      );
      expect(parsed, isNotNull);
      expect(parsed!.type, 'http-response');
    });
  });

  group('parseBodyRewriteRules', () {
    test('converts lines to config maps and skips invalid ones', () {
      final rules = parseBodyRewriteRules([
        r'http-response ^https://a\.example\.com/ foo bar',
        r'http-response-jq ^https://b\.example\.com/ del(.x)',
        'garbage line',
      ]);
      expect(rules, hasLength(2));
      expect(rules[0], {
        'type': 'http-response',
        'pattern': r'^https://a\.example\.com/',
        'regex': 'foo',
        'replacement': 'bar',
        'jq': '',
      });
      expect(rules[1]['type'], 'http-response-jq');
      expect(rules[1]['jq'], 'del(.x)');
    });
  });

  group('section parsing', () {
    test('parseSgmodule reads [Body Rewrite]', () {
      final sg = parseSgmodule(
        '#!name=Ads\n[Body Rewrite]\n'
        r'http-response-jq ^https://api\.example\.com/feed del(.ads)'
        '\n',
      );
      expect(sg.bodyRewrites, hasLength(1));
      expect(sg.needsMitm, isTrue);
      expect(sg.isEmpty, isFalse);
    });

    test('parseConf reads [Body Rewrite]', () {
      final conf = parseConf(
        '[Body Rewrite]\n'
        r'http-response ^https://a\.example\.com/ evil good'
        '\n',
      );
      expect(conf.bodyRewrites, hasLength(1));
      expect(conf.isEmpty, isFalse);
    });

    test('module arguments substitute inside [Body Rewrite]', () {
      final sg = parseSgmoduleWithArguments(
        '#!name=Ads\n#!arguments=host:example.com\n[Body Rewrite]\n'
        r'http-response-jq ^https://{{{host}}}/feed del(.ads)'
        '\n',
        const {},
      );
      expect(sg.bodyRewrites.single, contains('example.com'));
    });
  });
}
