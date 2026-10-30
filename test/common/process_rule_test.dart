import 'package:fl_clash/common/process_rule.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('processRuleActions', () {
    test('covers exactly the six process types mihomo parses', () {
      expect(processRuleActions, [
        RuleAction.PROCESS_NAME,
        RuleAction.PROCESS_PATH,
        RuleAction.PROCESS_NAME_REGEX,
        RuleAction.PROCESS_PATH_REGEX,
        RuleAction.PROCESS_NAME_WILDCARD,
        RuleAction.PROCESS_PATH_WILDCARD,
      ]);
    });

    test('identifies only process actions', () {
      expect(isProcessRuleAction(RuleAction.PROCESS_NAME), isTrue);
      expect(isProcessRuleAction(RuleAction.PROCESS_PATH), isTrue);
      expect(isProcessRuleAction(RuleAction.DOMAIN_SUFFIX), isFalse);
      expect(isProcessRuleAction(RuleAction.MATCH), isFalse);
    });
  });

  group('validateProcessRuleContent', () {
    test('accepts a bare exe name', () {
      expect(
        validateProcessRuleContent(RuleAction.PROCESS_NAME, 'chrome.exe'),
        isNull,
      );
    });

    test('rejects a path given as a process name', () {
      expect(
        validateProcessRuleContent(
          RuleAction.PROCESS_NAME,
          r'C:\Program Files\app\app.exe',
        ),
        ProcessRuleContentError.nameContainsPath,
      );
      expect(
        validateProcessRuleContent(RuleAction.PROCESS_NAME, '/usr/bin/chrome'),
        ProcessRuleContentError.nameContainsPath,
      );
    });

    test('accepts a full process path', () {
      expect(
        validateProcessRuleContent(
          RuleAction.PROCESS_PATH,
          r'C:\Program Files\app\app.exe',
        ),
        isNull,
      );
      expect(
        validateProcessRuleContent(RuleAction.PROCESS_PATH, '/usr/bin/chrome'),
        isNull,
      );
    });

    test('rejects a bare name given as a process path', () {
      expect(
        validateProcessRuleContent(RuleAction.PROCESS_PATH, 'chrome.exe'),
        ProcessRuleContentError.pathNotFull,
      );
    });

    test('rejects an invalid regex', () {
      expect(
        validateProcessRuleContent(RuleAction.PROCESS_NAME_REGEX, 'chrome('),
        ProcessRuleContentError.invalidRegex,
      );
      expect(
        validateProcessRuleContent(RuleAction.PROCESS_PATH_REGEX, r'^C:\\'),
        isNull,
      );
    });

    test('accepts wildcard payloads without further checks', () {
      expect(
        validateProcessRuleContent(
          RuleAction.PROCESS_NAME_WILDCARD,
          '*chrome*',
        ),
        isNull,
      );
      expect(
        validateProcessRuleContent(
          RuleAction.PROCESS_PATH_WILDCARD,
          r'C:\*\app.exe',
        ),
        isNull,
      );
    });

    test('ignores non-process actions', () {
      expect(
        validateProcessRuleContent(RuleAction.DOMAIN, 'example.com'),
        isNull,
      );
    });
  });

  group('process rule parse and serialize round-trip', () {
    test('round-trips every process type', () {
      for (final value in const [
        'PROCESS-NAME,chrome.exe,PROXY',
        r'PROCESS-PATH,C:\Program Files\app\app.exe,DIRECT',
        r'PROCESS-NAME-REGEX,^chrome.*\.exe$,PROXY',
        r'PROCESS-PATH-REGEX,^C:\\.*\\app\.exe$,DIRECT',
        'PROCESS-NAME-WILDCARD,*chrome*,PROXY',
        r'PROCESS-PATH-WILDCARD,C:\*\app.exe,DIRECT',
      ]) {
        expect(Rule.parse(value).rawValue, value, reason: value);
      }
    });

    test('keeps commas inside a process regex payload', () {
      const value = r'PROCESS-NAME-REGEX,^chrome{1,3}\.exe$,PROXY';
      final rule = Rule.parse(value);
      expect(rule.ruleAction, RuleAction.PROCESS_NAME_REGEX);
      expect(rule.content, r'^chrome{1,3}\.exe$');
      expect(rule.ruleTarget, 'PROXY');
      expect(rule.rawValue, value);
    });

    test('parses process rules case-insensitively like mihomo', () {
      final rule = Rule.parse('process-name,chrome.exe,PROXY');
      expect(rule.ruleAction, RuleAction.PROCESS_NAME);
      expect(rule.content, 'chrome.exe');
    });
  });
}
