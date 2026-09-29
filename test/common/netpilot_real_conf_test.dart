import 'dart:io';

import 'package:fl_clash/common/shadowrocket.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses user real NetPilot conf', () {
    final file = File(
      '/home/hatch/workspace/netpilot-test/NetPilot_Route_main.conf',
    );
    expect(file.existsSync(), isTrue, reason: 'real conf file must exist');
    final content = file.readAsStringSync();
    final data = parseConf(content);

    expect(data.isEmpty, isFalse);

    // The user's conf has these sections
    expect(data.rules.isNotEmpty, isTrue, reason: 'should have rules');
    expect(data.hosts.isNotEmpty, isTrue, reason: 'should have hosts');
    expect(
      data.urlRewrites.isNotEmpty,
      isTrue,
      reason: 'should have url rewrites',
    );

    // Check specific rules from user's conf
    final ruleStrs = data.rules.map((r) => r.toString()).toList();

    // The AND rule with REJECT-NO-DROP should be normalized
    final hasAndRule =
        ruleStrs.any((r) => r.contains('AND') && r.contains('REJECT'));
    expect(
      hasAndRule,
      isTrue,
      reason: 'AND((PROTOCOL,UDP),(DEST-PORT,443)),REJECT-NO-DROP normalized',
    );

    // FINAL should become MATCH
    final hasMatch = ruleStrs.any((r) => r.contains('MATCH'));
    expect(hasMatch, isTrue, reason: 'FINAL should become MATCH');

    // PROTOCOL should become NETWORK, DEST-PORT should become DST-PORT
    final hasNetwork = ruleStrs.any((r) => r.contains('NETWORK'));
    expect(hasNetwork, isTrue, reason: 'PROTOCOL should become NETWORK');
    final hasDstPort = ruleStrs.any((r) => r.contains('DST-PORT'));
    expect(hasDstPort, isTrue, reason: 'DEST-PORT should become DST-PORT');

    // Check hosts
    expect(data.hosts.containsKey('localhost'), isTrue);

    // Check URL rewrites
    expect(data.urlRewrites.length, 2);

    // Check MITM section
    expect(data.mitm['enable'], 'true');
    final hostname = data.mitm['hostname'] as String? ?? '';
    expect(hostname.contains('gs-loc.apple.com'), isTrue);

    // Check General section
    expect(data.general.containsKey('dns-server'), isTrue);
    expect(data.general.containsKey('skip-proxy'), isTrue);
  });
}
