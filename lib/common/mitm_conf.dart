import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persists the `[MITM]` section of an imported `.conf` so [MitmManager]
/// can pick it up at startup. Standalone file (not exported from
/// `common.dart`) to avoid import cycles.
class MitmConf {
  static Future<void> save({
    required bool enabled,
    required List<String> hostnames,
  }) async {
    try {
      if (!enabled && hostnames.isEmpty) return;
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/pigcat_mitm.json');
      await file.writeAsString(
        json.encode({'enabled': enabled, 'hostnames': hostnames}),
      );
    } catch (_) {}
  }

  static Future<({bool enabled, List<String> hostnames})> load() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final file = File('${docDir.path}/pigcat_mitm.json');
      if (!await file.exists()) {
        return (enabled: false, hostnames: <String>[]);
      }
      final data = json.decode(await file.readAsString());
      final enabled = data['enabled'] == true;
      final hostnames = (data['hostnames'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
      return (enabled: enabled, hostnames: hostnames);
    } catch (_) {
      return (enabled: false, hostnames: <String>[]);
    }
  }
}
