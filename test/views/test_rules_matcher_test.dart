import 'package:fl_clash/views/test_rules/rule_matcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestTarget.parse', () {
    test('parses a bare domain', () {
      final target = TestTarget.parse('Example.COM', 443, 'TCP');
      expect(target?.host, 'example.com');
      expect(target?.port, 443);
      expect(target?.ip, isNull);
    });

    test('parses a URL with port', () {
      final target = TestTarget.parse('https://example.com:8443/x', 443, 'TCP');
      expect(target?.host, 'example.com');
      expect(target?.port, 8443);
      expect(target?.url, isNotNull);
    });

    test('parses an IPv4 literal', () {
      final target = TestTarget.parse('1.1.1.1', 53, 'UDP');
      expect(target?.ip, '1.1.1.1');
      expect(target?.port, 53);
    });

    test('parses host:port', () {
      final target = TestTarget.parse('example.com:8080', 443, 'TCP');
      expect(target?.host, 'example.com');
      expect(target?.port, 8080);
    });

    test('rejects empty input', () {
      expect(TestTarget.parse('  ', 443, 'TCP'), isNull);
    });
  });

  group('findFirstMatch', () {
    final rules = [
      'DOMAIN-SUFFIX,google.com,PROXY',
      'DOMAIN,example.com,DIRECT',
      'IP-CIDR,1.1.1.0/24,DIRECT',
      'DST-PORT,443,PROXY',
      'MATCH,DIRECT',
    ];

    test('matches domain suffix first', () {
      final target = TestTarget.parse('www.google.com', 80, 'TCP')!;
      final verdict = findFirstMatch(rules, target)!;
      expect(verdict.certain, isTrue);
      expect(verdict.index, 0);
      expect(verdict.target, 'PROXY');
    });

    test('matches exact domain', () {
      final target = TestTarget.parse('example.com', 80, 'TCP')!;
      final verdict = findFirstMatch(rules, target)!;
      expect(verdict.index, 1);
      expect(verdict.target, 'DIRECT');
    });

    test('matches ip cidr', () {
      final target = TestTarget.parse('1.1.1.8', 80, 'TCP')!;
      final verdict = findFirstMatch(rules, target)!;
      expect(verdict.index, 2);
    });

    test('matches dst port', () {
      final target = TestTarget.parse('other.org', 443, 'TCP')!;
      final verdict = findFirstMatch(rules, target)!;
      expect(verdict.index, 3);
    });

    test('falls through to MATCH', () {
      final target = TestTarget.parse('other.org', 80, 'TCP')!;
      final verdict = findFirstMatch(rules, target)!;
      expect(verdict.index, 4);
      expect(verdict.target, 'DIRECT');
    });

    test('reports uncertain for geo rules', () {
      final target = TestTarget.parse('other.org', 80, 'TCP')!;
      final verdict = findFirstMatch(['GEOIP,CN,DIRECT'], target)!;
      expect(verdict.certain, isFalse);
    });

    test('evaluates AND/OR/NOT', () {
      final and = ['AND,((DOMAIN-SUFFIX,example.com),(DST-PORT,443)),PROXY'];
      var target = TestTarget.parse('a.example.com', 443, 'TCP')!;
      expect(findFirstMatch(and, target)?.certain, isTrue);
      target = TestTarget.parse('a.example.com', 80, 'TCP')!;
      expect(findFirstMatch(and, target), isNull);

      final or = ['OR,((DOMAIN-SUFFIX,example.com),(DST-PORT,443)),PROXY'];
      target = TestTarget.parse('other.org', 443, 'TCP')!;
      expect(findFirstMatch(or, target)?.certain, isTrue);

      final not = ['NOT,((DST-PORT,443)),PROXY'];
      target = TestTarget.parse('other.org', 80, 'TCP')!;
      expect(findFirstMatch(not, target)?.certain, isTrue);
    });

    test('matches port ranges', () {
      final target = TestTarget.parse('other.org', 8080, 'TCP')!;
      final verdict = findFirstMatch(['DST-PORT,8000-9000,PROXY'], target);
      expect(verdict?.certain, isTrue);
    });

    test('returns null when nothing matches', () {
      final target = TestTarget.parse('other.org', 80, 'TCP')!;
      expect(findFirstMatch(['DOMAIN,example.com,PROXY'], target), isNull);
    });
  });
}
