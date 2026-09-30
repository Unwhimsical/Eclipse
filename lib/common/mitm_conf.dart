import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'path.dart';

/// Persists the `[MITM]` section of an imported `.conf` so [MitmManager]
/// can pick it up at startup. Uses [appPath] instead of `path_provider`
/// directly (path_provider in lib/common breaks flutter analyze).
/// Standalone file, not exported from `common.dart`.
class MitmConf {
  static Future<File> _file() async {
    final dir = Directory(p.join(await appPath.homeDirPath, 'mitm'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File(p.join(dir.path, 'pigcat_mitm.json'));
  }

  static Future<void> save({
    required bool enabled,
    required List<String> hostnames,
  }) async {
    try {
      if (!enabled && hostnames.isEmpty) return;
      final file = await _file();
      await file.writeAsString(
        json.encode({'enabled': enabled, 'hostnames': hostnames}),
      );
    } catch (_) {}
  }

  static Future<({bool enabled, List<String> hostnames})> load() async {
    try {
      final file = await _file();
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
