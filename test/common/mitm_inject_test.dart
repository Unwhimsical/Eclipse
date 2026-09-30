import 'package:fl_clash/common/shadowrocket.dart';
import 'package:fl_clash/common/task.dart';
import 'package:flutter_test/flutter_test.dart';

Sgmodule _module(String content) => parseSgmodule(content);

void main() {
  group('extractRewriteHostname', () {
    test('extracts host from ^https?:// pattern', () {
      expect(
        extractRewriteHostname(r'^https?://example.com/path 302'),
        'example.com',
      );
    });

    test('unescapes regex dots in host', () {
      expect(
        extractRewriteHostname(r'^https://gs-loc\.apple\.com/path 302'),
        'gs-loc.apple.com',
      );
    });

    test('returns null when no host is recognizable', () {
      expect(extractRewriteHostname(r'^/just/a/path 302'), isNull);
      expect(extractRewriteHostname(''), isNull);
    });

    test('returns null for wildcard-only host', () {
      expect(extractRewriteHostname(r'^https?://(.*)/path 302'), isNull);
    });
  });

  group('collectMitmHostnames', () {
    test('dedupes case-insensitively', () {
      final hosts = collectMitmHostnames(
        modules: [],
        profileMitmHostnames: ['GS-LOC.APPLE.COM', 'gs-loc.apple.com'],
        profileUrlRewrites: [],
      );
      expect(hosts, ['gs-loc.apple.com']);
    });

    test('lowercases wildcard entries', () {
      final hosts = collectMitmHostnames(
        modules: [],
        profileMitmHostnames: ['*.Example.COM'],
        profileUrlRewrites: [],
      );
      expect(hosts, ['*.example.com']);
    });

    test('merges module and profile hostnames', () {
      final hosts = collectMitmHostnames(
        modules: [_module('[MITM]\nhostname = mod.example.com\n')],
        profileMitmHostnames: ['profile.example.com'],
        profileUrlRewrites: [],
      );
      expect(hosts, {'mod.example.com', 'profile.example.com'});
    });

    test('derives hosts from profile and module rewrites', () {
      final hosts = collectMitmHostnames(
        modules: [
          _module('[URL Rewrite]\n^https?://rewritten\\.example\\.com/x 302\n'),
        ],
        profileMitmHostnames: [],
        profileUrlRewrites: [r'^https?://profile-rewrite.example.com/y 302'],
      );
      expect(hosts, {'rewritten.example.com', 'profile-rewrite.example.com'});
    });

    test('dedupes explicit hostnames with derived ones', () {
      final hosts = collectMitmHostnames(
        modules: [],
        profileMitmHostnames: ['Example.COM'],
        profileUrlRewrites: [r'^https?://example.com/path 302'],
      );
      expect(hosts, ['example.com']);
    });
  });

  group('mitmRulesForHosts', () {
    test('builds DOMAIN and DOMAIN-SUFFIX rules', () {
      final rules = mitmRulesForHosts({'example.com', '*.example.org'});
      expect(
        rules,
        containsAll([
          'DOMAIN,example.com,PigCat-MITM',
          'DOMAIN-SUFFIX,example.org,PigCat-MITM',
        ]),
      );
      expect(rules, hasLength(2));
    });

    test('skips exclusions and directives', () {
      final rules = mitmRulesForHosts({
        '-excluded.com',
        '!negated.com',
        '%APPEND%',
        'kept.com',
      });
      expect(rules, ['DOMAIN,kept.com,PigCat-MITM']);
    });

    test('returns empty for empty hosts', () {
      expect(mitmRulesForHosts({}), isEmpty);
    });
  });
}
