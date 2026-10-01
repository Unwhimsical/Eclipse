import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';

class TestTarget {
  final String host;
  final String? ip;
  final int port;
  final String network;
  final String? url;
  final String? process;

  const TestTarget({
    required this.host,
    this.ip,
    required this.port,
    required this.network,
    this.url,
    this.process,
  });

  static TestTarget? parse(String input, int port, String network) {
    final text = input.trim();
    if (text.isEmpty) return null;
    String? url;
    var host = text;
    var resolvedPort = port;
    if (text.contains('://')) {
      final uri = Uri.tryParse(text);
      if (uri == null || uri.host.isEmpty) return null;
      url = text;
      host = uri.host;
      if (uri.hasPort) {
        resolvedPort = uri.port;
      } else if (uri.scheme == 'https') {
        resolvedPort = 443;
      } else if (uri.scheme == 'http') {
        resolvedPort = 80;
      }
    } else if (text.startsWith('[')) {
      final end = text.indexOf(']');
      if (end < 0) return null;
      host = text.substring(1, end);
      final rest = text.substring(end + 1);
      if (rest.startsWith(':')) {
        resolvedPort = int.tryParse(rest.substring(1)) ?? resolvedPort;
      }
    } else {
      final colon = text.lastIndexOf(':');
      if (colon > 0 && !text.substring(0, colon).contains(':')) {
        final maybePort = int.tryParse(text.substring(colon + 1));
        if (maybePort != null) {
          host = text.substring(0, colon);
          resolvedPort = maybePort;
        }
      }
    }
    host = host.toLowerCase();
    if (host.isEmpty) return null;
    final asIp = InternetAddress.tryParse(host);
    return TestTarget(
      host: host,
      ip: asIp?.address,
      port: resolvedPort,
      network: network,
      url: url,
      process: null,
    );
  }
}

class RuleMatchVerdict {
  final int index;
  final String rawRule;
  final String? target;
  final bool certain;

  const RuleMatchVerdict({
    required this.index,
    required this.rawRule,
    required this.target,
    required this.certain,
  });
}

BigInt _addressToInt(InternetAddress address) {
  var value = BigInt.zero;
  for (final byte in address.rawAddress) {
    value = (value << 8) | BigInt.from(byte);
  }
  return value;
}

bool _cidrContains(String cidr, String ip) {
  final slash = cidr.indexOf('/');
  if (slash < 0) return false;
  final base = InternetAddress.tryParse(cidr.substring(0, slash).trim());
  final bits = int.tryParse(cidr.substring(slash + 1).trim());
  final addr = InternetAddress.tryParse(ip);
  if (base == null || bits == null || addr == null) return false;
  if (base.type != addr.type) return false;
  final width = base.type == InternetAddressType.IPv4 ? 32 : 128;
  if (bits < 0 || bits > width) return false;
  final mask = bits == 0
      ? BigInt.zero
      : ((BigInt.one << width) - BigInt.one) ^
            ((BigInt.one << (width - bits)) - BigInt.one);
  return (_addressToInt(base) & mask) == (_addressToInt(addr) & mask);
}

bool _portMatches(String payload, int port) {
  for (final part in payload.split(',')) {
    final item = part.trim();
    if (item.isEmpty) continue;
    final dash = item.indexOf('-');
    if (dash >= 0) {
      final from = int.tryParse(item.substring(0, dash).trim());
      final to = int.tryParse(item.substring(dash + 1).trim());
      if (from != null && to != null && port >= from && port <= to) {
        return true;
      }
    } else if (int.tryParse(item) == port) {
      return true;
    }
  }
  return false;
}

bool _wildcardMatches(String pattern, String value) {
  final escaped = RegExp.escape(pattern).replaceAll(r'\*', '.*');
  return RegExp('^$escaped\$', caseSensitive: false).hasMatch(value);
}

List<String> _splitTopLevel(String text) {
  final parts = <String>[];
  var depth = 0;
  var current = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final char = text[i];
    if (char == '(') depth++;
    if (char == ')') depth--;
    if (char == ',' && depth == 0) {
      parts.add(current.toString());
      current = StringBuffer();
    } else {
      current.write(char);
    }
  }
  parts.add(current.toString());
  return parts;
}

List<Rule> _parseCompound(String payload) {
  var text = payload.trim();
  while (text.startsWith('(') && text.endsWith(')')) {
    var depth = 0;
    var wrapsAll = true;
    for (var i = 0; i < text.length; i++) {
      if (text[i] == '(') depth++;
      if (text[i] == ')') depth--;
      if (depth == 0 && i < text.length - 1) {
        wrapsAll = false;
        break;
      }
    }
    if (!wrapsAll) break;
    text = text.substring(1, text.length - 1).trim();
  }
  final rules = <Rule>[];
  for (final part in _splitTopLevel(text)) {
    var item = part.trim();
    if (item.startsWith('(') && item.endsWith(')')) {
      item = item.substring(1, item.length - 1);
    }
    if (item.isEmpty) continue;
    rules.add(Rule.parse(item));
  }
  return rules;
}

bool? _matchSingle(Rule rule, TestTarget target) {
  final content = rule.content;
  switch (rule.ruleAction) {
    case RuleAction.MATCH:
      return true;
    case RuleAction.DOMAIN:
      if (content == null) return false;
      return target.host == content.toLowerCase();
    case RuleAction.DOMAIN_SUFFIX:
      if (content == null) return false;
      final suffix = content.toLowerCase();
      return target.host == suffix || target.host.endsWith('.$suffix');
    case RuleAction.DOMAIN_KEYWORD:
      if (content == null) return false;
      return target.host.contains(content.toLowerCase());
    case RuleAction.DOMAIN_REGEX:
      if (content == null) return false;
      return RegExp(content).hasMatch(target.host);
    case RuleAction.DOMAIN_WILDCARD:
      if (content == null) return false;
      return _wildcardMatches(content, target.host);
    case RuleAction.IP_CIDR:
    case RuleAction.IP_CIDR6:
      if (content == null || target.ip == null) return null;
      return _cidrContains(content, target.ip!);
    case RuleAction.IP_SUFFIX:
      if (content == null || target.ip == null) return null;
      return target.ip!.contains(content);
    case RuleAction.DST_PORT:
    case RuleAction.SRC_PORT:
    case RuleAction.IN_PORT:
      if (content == null) return false;
      return _portMatches(content, target.port);
    case RuleAction.NETWORK:
      if (content == null) return false;
      return target.network.toLowerCase() == content.toLowerCase();
    case RuleAction.PROCESS_NAME:
      if (content == null) return false;
      final process = target.process;
      if (process == null || process.isEmpty) return null;
      return process == content;
    case RuleAction.PROCESS_PATH:
      if (content == null) return false;
      final process = target.process;
      if (process == null || process.isEmpty) return null;
      return process == content;
    case RuleAction.PROCESS_NAME_REGEX:
    case RuleAction.PROCESS_PATH_REGEX:
      if (content == null) return false;
      final process = target.process;
      if (process == null || process.isEmpty) return null;
      return RegExp(content).hasMatch(process);
    case RuleAction.PROCESS_NAME_WILDCARD:
    case RuleAction.PROCESS_PATH_WILDCARD:
      if (content == null) return false;
      final process = target.process;
      if (process == null || process.isEmpty) return null;
      return _wildcardMatches(content, process);
    case RuleAction.AND:
      if (content == null) return false;
      var unknown = false;
      for (final sub in _parseCompound(content)) {
        final verdict = _matchSingle(sub, target);
        if (verdict == false) return false;
        if (verdict == null) unknown = true;
      }
      return unknown ? null : true;
    case RuleAction.OR:
      if (content == null) return false;
      var unknown = false;
      for (final sub in _parseCompound(content)) {
        final verdict = _matchSingle(sub, target);
        if (verdict == true) return true;
        if (verdict == null) unknown = true;
      }
      return unknown ? null : false;
    case RuleAction.NOT:
      if (content == null) return false;
      final subs = _parseCompound(content);
      if (subs.isEmpty) return false;
      final verdict = _matchSingle(subs.first, target);
      if (verdict == null) return null;
      return !verdict;
    case RuleAction.GEOSITE:
    case RuleAction.GEOIP:
    case RuleAction.SRC_GEOIP:
    case RuleAction.IP_ASN:
    case RuleAction.SRC_IP_ASN:
    case RuleAction.SRC_IP_CIDR:
    case RuleAction.SRC_IP_SUFFIX:
    case RuleAction.RULE_SET:
    case RuleAction.SUB_RULE:
    case RuleAction.IN_TYPE:
    case RuleAction.IN_USER:
    case RuleAction.IN_NAME:
    case RuleAction.REMATCH_NAME:
    case RuleAction.UID:
    case RuleAction.DSCP:
      return null;
  }
}

RuleMatchVerdict? findFirstMatch(List<String> rawRules, TestTarget target) {
  RuleMatchVerdict? firstUncertain;
  for (var i = 0; i < rawRules.length; i++) {
    final raw = rawRules[i];
    if (raw.trim().isEmpty) continue;
    final rule = Rule.parse(raw);
    final verdict = _matchSingle(rule, target);
    if (verdict == true) {
      return RuleMatchVerdict(
        index: i,
        rawRule: raw,
        target: rule.realTarget,
        certain: true,
      );
    }
    if (verdict == null && firstUncertain == null) {
      firstUncertain = RuleMatchVerdict(
        index: i,
        rawRule: raw,
        target: rule.realTarget,
        certain: false,
      );
    }
  }
  return firstUncertain;
}
