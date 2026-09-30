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

    test('preserves exclusion entries for the Go matcher', () {
      final hosts = collectMitmHostnames(
        modules: [
          _module('[MITM]\nhostname = *.example.com, -Foo.Example.COM\n'),
        ],
        profileMitmHostnames: ['!Bar.Example.COM'],
        profileUrlRewrites: [],
      );
      expect(hosts, {'*.example.com', '-foo.example.com', '!bar.example.com'});
    });

    test('derives hosts from map local lines', () {
      final hosts = collectMitmHostnames(
        modules: [
          _module(
            '[Map Local]\n'
            r'^https://ads\.example\.com/pixel data-type=tiny-gif'
            '\n',
          ),
        ],
        profileMitmHostnames: [],
        profileUrlRewrites: [],
        profileMapLocal: [
          r'^https://cdn\.example\.net/lib.js data-type=text data=""',
        ],
      );
      expect(hosts, {'ads.example.com', 'cdn.example.net'});
    });

    test('derives hosts from body rewrite patterns', () {
      final hosts = collectMitmHostnames(
        modules: [
          _module(
            '[Body Rewrite]\n'
            r'http-response-jq ^https://api\.example\.com/feed del(.ads)'
            '\n',
          ),
        ],
        profileMitmHostnames: [],
        profileUrlRewrites: [],
        profileBodyRewrites: [
          r'http-request ^https://up\.example\.org/submit token SECRET',
        ],
      );
      expect(hosts, {'api.example.com', 'up.example.org'});
    });
  });

  group('extractBodyRewriteHostname', () {
    test('uses the URL pattern token, not the type', () {
      expect(
        extractBodyRewriteHostname(
          r'http-response-jq ^https://api\.example\.com/feed del(.ads)',
        ),
        'api.example.com',
      );
    });

    test('returns null for short lines', () {
      expect(extractBodyRewriteHostname('http-response'), isNull);
      expect(extractBodyRewriteHostname(''), isNull);
    });
  });

  group('mitmRulesForHosts', () {
    test('builds DOMAIN and DOMAIN-SUFFIX rules', () {
      final rules = mitmRulesForHosts({'example.com', '*.example.org'});
      expect(
        rules,
        containsAll([
          'DOMAIN,example.com,Eclipse-MITM',
          'DOMAIN-SUFFIX,example.org,Eclipse-MITM',
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
      expect(rules, ['DOMAIN,kept.com,Eclipse-MITM']);
    });

    test('returns empty for empty hosts', () {
      expect(mitmRulesForHosts({}), isEmpty);
    });
  });
}
