import 'package:fl_clash/common/task.dart';
import 'package:flutter_test/flutter_test.dart';

({Set<String> ruleSet, bool rulesAppend}) mod(
  List<String> rules, {
  bool append = true,
}) => (ruleSet: rules.toSet(), rulesAppend: append);

void main() {
  group('orderRulesByModules', () {
    const aRule = 'DOMAIN-SUFFIX,a.com,PROXY';
    const bRule = 'DOMAIN-SUFFIX,b.com,PROXY';
    const cfgRule = 'DOMAIN-SUFFIX,cfg.com,DIRECT';
    const matchRule = 'MATCH,PROXY';

    test('two append modules keep module order then config rules', () {
      final out = orderRulesByModules(
        [cfgRule, aRule, matchRule, bRule],
        [
          mod([aRule]),
          mod([bRule]),
        ],
      );
      expect(out, [aRule, bRule, cfgRule, matchRule]);
    });

    test('overwrite module drops config rules and earlier modules', () {
      final out = orderRulesByModules(
        [aRule, bRule, cfgRule],
        [
          mod([aRule]),
          mod([bRule], append: false),
        ],
      );
      expect(out, [bRule]);
    });

    test('append after overwrite keeps both modules', () {
      final out = orderRulesByModules(
        [aRule, bRule, cfgRule],
        [
          mod([aRule], append: false),
          mod([bRule]),
        ],
      );
      expect(out, [aRule, bRule]);
    });

    test('later overwrite wins over earlier overwrite', () {
      final out = orderRulesByModules(
        [aRule, bRule, cfgRule],
        [
          mod([aRule], append: false),
          mod([bRule], append: false),
        ],
      );
      expect(out, [bRule]);
    });

    test('first-match-wins keeps rule order stable', () {
      final out = orderRulesByModules(
        [bRule, aRule, cfgRule],
        [
          mod([aRule]),
          mod([bRule]),
        ],
      );
      expect(out, [aRule, bRule, cfgRule]);
    });

    test('no modules leaves rules untouched', () {
      final out = orderRulesByModules([cfgRule, matchRule], []);
      expect(out, [cfgRule, matchRule]);
    });

    test('rule matching no module stays with config rules', () {
      final out = orderRulesByModules(
        [aRule, cfgRule],
        [
          mod([bRule]),
        ],
      );
      expect(out, [aRule, cfgRule]);
    });
  });
}
