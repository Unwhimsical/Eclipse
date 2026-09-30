import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';

/// Per-profile MITM configuration stored as `<profileId>.mitm.json`
/// alongside the profile's YAML file. Avoids database migration.
class MitmStore {
  static Future<File> _file(int profileId) async {
    final dir = await appPath.getProfilePath('');
    // getProfilePath('') gives the directory; construct file path.
    final base = dir.endsWith('/') ? dir : '$dir/';
    // Actually getProfilePath(id) returns the full path for id.yaml.
    // Derive directory from it.
    final yamlPath = await appPath.getProfilePath(profileId.toString());
    final sep = yamlPath.lastIndexOf('/');
    final directory = sep > 0 ? yamlPath.substring(0, sep) : base;
    return File('$directory/$profileId.mitm.json');
  }

  /// Save MITM config for a profile.
  static Future<void> save(
    int profileId, {
    required bool enabled,
    required List<String> hostnames,
  }) async {
    final file = await _file(profileId);
    final data = {'enabled': enabled, 'hostnames': hostnames};
    await file.writeAsString(json.encode(data));
  }

  /// Load MITM config for a profile. Returns (enabled, hostnames).
  static Future<({bool enabled, List<String> hostnames})> load(
    int profileId,
  ) async {
    try {
      final file = await _file(profileId);
      if (!await file.exists()) {
        return (enabled: false, hostnames: const []);
      }
      final data = json.decode(await file.readAsString());
      final enabled = data['enabled'] == true;
      final hostnames =
          (data['hostnames'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[];
      return (enabled: enabled, hostnames: hostnames);
    } catch (_) {
      return (enabled: false, hostnames: const []);
    }
  }

  /// Delete MITM config for a profile.
  static Future<void> delete(int profileId) async {
    try {
      final file = await _file(profileId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
