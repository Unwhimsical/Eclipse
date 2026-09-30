import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Per-profile MITM configuration stored as `<profileId>.mitm.json`
/// in the app's documents directory. Avoids database migration.
/// Uses path_provider directly to avoid import cycles with common.dart.
class MitmStore {
  static Future<Directory> _dir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docDir.path}/mitm');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> _file(int profileId) async {
    final dir = await _dir();
    return File('${dir.path}/$profileId.mitm.json');
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
