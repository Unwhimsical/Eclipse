import 'package:fl_clash/common/include.dart';
import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';

IncludeFetcher _pages(Map<String, String> pages) {
  return (url) async => pages[url];
}

void main() {
  group('mergeConfData', () {
    test('concatenates lists with local entries first', () {
      final base = parseConf('[Rule]\nDOMAIN,local.example,PROXY\n');
      final overlay = parseConf('[Rule]\nDOMAIN,remote.example,DIRECT\n');
      final merged = mergeConfData(base, overlay);
      expect(merged.rules, [
        'DOMAIN,local.example,PROXY',
        'DOMAIN,remote.example,DIRECT',
      ]);
    });

    test('local map keys win on conflict and remote keys fill gaps', () {
      final base = parseConf(
        '[General]\ndns-server = 1.1.1.1\n[Host]\nlocal.example = 1.2.3.4\n',
      );
      final overlay = parseConf(
        '[General]\ndns-server = 9.9.9.9\nfallback-dns-server = 8.8.8.8\n'
        '[Host]\nlocal.example = 9.9.9.9\nremote.example = 5.6.7.8\n',
      );
      final merged = mergeConfData(base, overlay);
      expect(merged.general['dns-server'], '1.1.1.1');
      expect(merged.general['fallback-dns-server'], '8.8.8.8');
      expect(merged.hosts['local.example'], '1.2.3.4');
      expect(merged.hosts['remote.example'], '5.6.7.8');
    });
  });

  group('resolveConfIncludes', () {
    test('returns the conf untouched when there is no include', () async {
      var called = false;
      final conf = parseConf('[General]\ndns-server = 1.1.1.1\n');
      final merged = await resolveConfIncludes(
        conf,
        fetcher: (url) async {
          called = true;
          return null;
        },
      );
      expect(called, isFalse);
      expect(merged.general['dns-server'], '1.1.1.1');
    });

    test('merges a single include with local config winning', () async {
      final conf = parseConf(
        '[General]\ndns-server = 1.1.1.1\ninclude = https://example.com/remote.conf\n'
        '[Rule]\nDOMAIN,local.example,PROXY\n',
      );
      final merged = await resolveConfIncludes(
        conf,
        fetcher: _pages({
          'https://example.com/remote.conf':
              '[General]\ndns-server = 9.9.9.9\nfallback-dns-server = 8.8.8.8\n'
              '[Rule]\nDOMAIN,remote.example,DIRECT\n',
        }),
      );
      expect(merged.general['dns-server'], '1.1.1.1');
      expect(merged.general['fallback-dns-server'], '8.8.8.8');
      expect(merged.rules, [
        'DOMAIN,local.example,PROXY',
        'DOMAIN,remote.example,DIRECT',
      ]);
    });

    test('follows chained includes', () async {
      final conf = parseConf(
        '[General]\ninclude = https://example.com/a.conf\n'
        '[Rule]\nDOMAIN,local.example,PROXY\n',
      );
      final merged = await resolveConfIncludes(
        conf,
        fetcher: _pages({
          'https://example.com/a.conf':
              '[General]\ninclude = https://example.com/b.conf\n'
              '[Rule]\nDOMAIN,a.example,PROXY\n',
          'https://example.com/b.conf': '[Rule]\nDOMAIN,b.example,DIRECT\n',
        }),
      );
      expect(merged.rules, [
        'DOMAIN,local.example,PROXY',
        'DOMAIN,a.example,PROXY',
        'DOMAIN,b.example,DIRECT',
      ]);
    });

    test('stops on include cycles instead of looping', () async {
      final conf = parseConf(
        '[General]\ninclude = https://example.com/a.conf\n',
      );
      final merged = await resolveConfIncludes(
        conf,
        fetcher: _pages({
          'https://example.com/a.conf':
              '[General]\ninclude = https://example.com/b.conf\n'
              '[Rule]\nDOMAIN,a.example,PROXY\n',
          'https://example.com/b.conf':
              '[General]\ninclude = https://example.com/a.conf\n'
              '[Rule]\nDOMAIN,b.example,DIRECT\n',
        }),
      );
      expect(merged.rules, [
        'DOMAIN,a.example,PROXY',
        'DOMAIN,b.example,DIRECT',
      ]);
    });

    test('respects the depth limit', () async {
      final pages = <String, String>{};
      for (var i = 0; i < 8; i++) {
        final next = i + 1;
        pages['https://example.com/$i.conf'] =
            '[General]\ninclude = https://example.com/$next.conf\n'
            '[Rule]\nDOMAIN,$i.example,PROXY\n';
      }
      pages['https://example.com/8.conf'] = '[Rule]\nDOMAIN,8.example,PROXY\n';
      final conf = parseConf(
        '[General]\ninclude = https://example.com/0.conf\n',
      );
      final merged = await resolveConfIncludes(
        conf,
        fetcher: _pages(pages),
        maxDepth: 3,
      );
      expect(merged.rules, [
        'DOMAIN,0.example,PROXY',
        'DOMAIN,1.example,PROXY',
        'DOMAIN,2.example,PROXY',
      ]);
    });

    test('keeps the local config when the download fails', () async {
      final conf = parseConf(
        '[General]\ndns-server = 1.1.1.1\ninclude = https://example.com/gone.conf\n'
        '[Rule]\nDOMAIN,local.example,PROXY\n',
      );
      final merged = await resolveConfIncludes(conf, fetcher: _pages({}));
      expect(merged.general['dns-server'], '1.1.1.1');
      expect(merged.rules, ['DOMAIN,local.example,PROXY']);
    });

    test('keeps the local config when the download is empty', () async {
      final conf = parseConf(
        '[General]\ndns-server = 1.1.1.1\ninclude = https://example.com/empty.conf\n',
      );
      final merged = await resolveConfIncludes(
        conf,
        fetcher: _pages({'https://example.com/empty.conf': ''}),
      );
      expect(merged.general['dns-server'], '1.1.1.1');
    });
  });
}
