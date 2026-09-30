import 'dart:convert';

import 'package:fl_clash/common/sr_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShadowrocketImport.parseLinkList', () {
    test('parses multiple links', () {
      final proxies = ShadowrocketImport.parseLinkList(
        'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388#one\n'
        'trojan://password@example.org:443#two\n',
      );
      expect(proxies, hasLength(2));
      expect(proxies[0]['name'], 'one');
      expect(proxies[1]['name'], 'two');
    });

    test('skips invalid lines', () {
      final proxies = ShadowrocketImport.parseLinkList(
        'not a link\n'
        'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388#one\n',
      );
      expect(proxies, hasLength(1));
    });

    test('decodes base64 subscription body', () {
      final body = base64Encode(
        utf8.encode(
          'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ=@example.com:8388#one\n'
          'trojan://password@example.org:443#two\n',
        ),
      );
      final proxies = ShadowrocketImport.parseLinkList(body);
      expect(proxies, hasLength(2));
    });

    test('returns empty for garbage', () {
      expect(ShadowrocketImport.parseLinkList(''), isEmpty);
      expect(ShadowrocketImport.parseLinkList('!!!not-base64!!!'), isEmpty);
    });
  });

  group('ShadowrocketImport.fileNameFromUrl', () {
    test('extracts file name', () {
      expect(
        ShadowrocketImport.fileNameFromUrl(
          'https://example.com/modules/test.sgmodule',
        ),
        'test.sgmodule',
      );
    });

    test('strips query params', () {
      expect(
        ShadowrocketImport.fileNameFromUrl(
          'https://example.com/a.conf?token=123',
        ),
        'a.conf',
      );
    });

    test('falls back to url when empty', () {
      expect(ShadowrocketImport.fileNameFromUrl(''), '');
    });
  });

  group('ShadowrocketImport MITM helpers', () {
    test('parseMitmEnabled reads the enable flag', () {
      expect(ShadowrocketImport.parseMitmEnabled({'enable': 'true'}), isTrue);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': 'TRUE'}), isTrue);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': ' true '}), isTrue);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': 'false'}), isFalse);
      expect(ShadowrocketImport.parseMitmEnabled({'enable': '1'}), isFalse);
      expect(ShadowrocketImport.parseMitmEnabled({}), isFalse);
    });

    test('parseMitmHostnames splits and trims the hostname list', () {
      expect(
        ShadowrocketImport.parseMitmHostnames({
          'hostname': 'gs-loc.apple.com, gs-loc-cn.apple.com',
        }),
        ['gs-loc.apple.com', 'gs-loc-cn.apple.com'],
      );
      expect(
        ShadowrocketImport.parseMitmHostnames({'hostname': 'a.com,, ,b.com,'}),
        ['a.com', 'b.com'],
      );
      expect(ShadowrocketImport.parseMitmHostnames({}), isEmpty);
      expect(ShadowrocketImport.parseMitmHostnames({'hostname': ''}), isEmpty);
    });
  });
}
