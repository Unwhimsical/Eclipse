import 'package:fl_clash/common/common.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('resolveProxyChain', () {
    test('a proxy without a via entry exits directly', () {
      expect(resolveProxyChain('A', const {}, {'A', 'B'}), ['A']);
      expect(resolveProxyChain('A', const {'B': 'C'}, {'A', 'B', 'C'}), ['A']);
    });

    test('follows multi-hop chains in order', () {
      const chains = {'A': 'B', 'B': 'C'};
      expect(resolveProxyChain('A', chains, {'A', 'B', 'C'}), ['A', 'B', 'C']);
    });

    test('stops when a link points at an unknown proxy', () {
      const chains = {'A': 'B', 'B': 'Ghost'};
      expect(resolveProxyChain('A', chains, {'A', 'B'}), ['A', 'B']);
    });

    test('stops at a loop and marks the repeated hop', () {
      const chains = {'A': 'B', 'B': 'A'};
      expect(resolveProxyChain('A', chains, {'A', 'B'}), ['A', 'B', 'A']);
    });
  });

  group('hasProxyChainLoop', () {
    test('empty and acyclic chains are loop-free', () {
      expect(hasProxyChainLoop(const {}), isFalse);
      expect(hasProxyChainLoop(const {'A': 'B', 'B': 'C'}), isFalse);
    });

    test('detects self references', () {
      expect(hasProxyChainLoop(const {'A': 'A'}), isTrue);
    });

    test('detects two-node cycles', () {
      expect(hasProxyChainLoop(const {'A': 'B', 'B': 'A'}), isTrue);
    });

    test('detects longer cycles reachable mid-chain', () {
      expect(hasProxyChainLoop(const {'A': 'B', 'B': 'C', 'C': 'B'}), isTrue);
    });

    test('ignores dangling links', () {
      expect(hasProxyChainLoop(const {'A': 'Ghost'}), isFalse);
    });
  });

  group('sanitizeProxyChains', () {
    test('keeps only entries both endpoints exist for', () {
      expect(
        sanitizeProxyChains(
          const {'A': 'B', 'B': 'Ghost', 'Ghost': 'A', '': 'B'},
          {'A', 'B'},
        ),
        {'A': 'B'},
      );
    });

    test('drops self references and empty targets', () {
      expect(
        sanitizeProxyChains(const {'A': 'A', 'B': ''}, {'A', 'B'}),
        isEmpty,
      );
    });
  });

  group('applyProxyChains', () {
    Map<String, dynamic> configWith(List<String> names) {
      return {
        'proxies': [
          for (final name in names) {'name': name, 'type': 'ss'},
        ],
      };
    }

    test('writes dialer-proxy for chained proxies only', () {
      final rawConfig = configWith(['A', 'B', 'C']);
      applyProxyChains(rawConfig, const {'A': 'B'});

      final proxies = rawConfig['proxies'] as List;
      expect(proxies[0]['dialer-proxy'], 'B');
      expect(proxies[1].containsKey('dialer-proxy'), isFalse);
      expect(proxies[2].containsKey('dialer-proxy'), isFalse);
    });

    test('skips stale entries instead of breaking core config', () {
      final rawConfig = configWith(['A', 'B']);
      applyProxyChains(rawConfig, const {'A': 'Ghost', 'Ghost': 'B', 'B': 'B'});

      final proxies = rawConfig['proxies'] as List;
      for (final proxy in proxies) {
        expect((proxy as Map).containsKey('dialer-proxy'), isFalse);
      }
    });

    test('never writes a looped chain into the core config', () {
      final rawConfig = configWith(['A', 'B']);
      applyProxyChains(rawConfig, const {'A': 'B', 'B': 'A'});

      final proxies = rawConfig['proxies'] as List;
      for (final proxy in proxies) {
        expect((proxy as Map).containsKey('dialer-proxy'), isFalse);
      }
    });

    test('does nothing without proxies or chains', () {
      final noProxies = <String, dynamic>{};
      applyProxyChains(noProxies, const {'A': 'B'});
      expect(noProxies.containsKey('proxies'), isFalse);

      final noChains = configWith(['A']);
      applyProxyChains(noChains, const {});
      expect(
        (noChains['proxies'] as List).single.containsKey('dialer-proxy'),
        isFalse,
      );
    });
  });
}
