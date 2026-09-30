import 'dart:convert';
import 'dart:io';

/// Per-profile MITM configuration stored as `<profileId>.mitm.json`
/// alongside the profile's YAML file. Avoids database migration.
/// Pure Dart (no Flutter deps) to avoid import cycles.
class MitmStore {
  static File _file(String directory, int profileId) {
    return File('$directory/$profileId.mitm.json');
  }

  /// Save MITM config for a profile.
  static Future<void> save(
    String directory,
    int profileId, {
    required bool enabled,
    required List<String> hostnames,
  }) async {
    final file = _file(directory, profileId);
    final data = {'enabled': enabled, 'hostnames': hostnames};
    await file.writeAsString(json.encode(data));
  }

  /// Load MITM config for a profile. Returns (enabled, hostnames).
  static Future<({bool enabled, List<String> hostnames})> load(
    String directory,
    int profileId,
  ) async {
    try {
      final file = _file(directory, profileId);
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
  static Future<void> delete(String directory, int profileId) async {
    try {
      final file = _file(directory, profileId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  /// Get the directory containing profile files from a profile YAML path.
  static String dirFromProfilePath(String yamlPath) {
    final sep = yamlPath.lastIndexOf('/');
    return sep > 0 ? yamlPath.substring(0, sep) : '.';
  }
}
