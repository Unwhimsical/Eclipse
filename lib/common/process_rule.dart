import 'package:fl_clash/enum/enum.dart';

const List<RuleAction> processRuleActions = [
  RuleAction.PROCESS_NAME,
  RuleAction.PROCESS_PATH,
  RuleAction.PROCESS_NAME_REGEX,
  RuleAction.PROCESS_PATH_REGEX,
  RuleAction.PROCESS_NAME_WILDCARD,
  RuleAction.PROCESS_PATH_WILDCARD,
];

bool isProcessRuleAction(RuleAction action) =>
    processRuleActions.contains(action);

enum ProcessRuleContentError { nameContainsPath, pathNotFull, invalidRegex }

ProcessRuleContentError? validateProcessRuleContent(
  RuleAction action,
  String content,
) {
  if (!isProcessRuleAction(action)) return null;
  switch (action) {
    case RuleAction.PROCESS_NAME:
      if (content.contains('/') || content.contains(r'\')) {
        return ProcessRuleContentError.nameContainsPath;
      }
    case RuleAction.PROCESS_PATH:
      if (!content.contains('/') && !content.contains(r'\')) {
        return ProcessRuleContentError.pathNotFull;
      }
    case RuleAction.PROCESS_NAME_REGEX:
    case RuleAction.PROCESS_PATH_REGEX:
      try {
        RegExp(content);
      } on FormatException {
        return ProcessRuleContentError.invalidRegex;
      }
    case RuleAction.PROCESS_NAME_WILDCARD:
    case RuleAction.PROCESS_PATH_WILDCARD:
      break;
    default:
      break;
  }
  return null;
}
